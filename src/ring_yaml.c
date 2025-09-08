#include "ring.h"
#include <yaml.h>
#include <stdarg.h>

// Constants defining limits for the YAML parser
#define RING_YAML_DOCUMENT "YAML_DOCUMENT"
#define MAX_YAML_SIZE (10 * 1024 * 1024)
#define MAX_RECURSION_DEPTH 100
#define MAX_NUMBER_LEN 255
#define ERROR_BUFFER_SIZE 1024

// Platform-specific thread-local storage definition
#if defined(_MSC_VER)
    #define RING_YAML_THREAD_LOCAL __declspec(thread)
#elif __STDC_VERSION__ >= 201112L && !defined(__STDC_NO_THREADS__)
    #include <threads.h>
    #define RING_YAML_THREAD_LOCAL thread_local
#elif defined(__GNUC__) || defined(__clang__)
    #define RING_YAML_THREAD_LOCAL __thread
#else
    #define RING_YAML_THREAD_LOCAL
#endif

// Thread-local error buffer for storing error messages
RING_YAML_THREAD_LOCAL static char g_szYamlError[ERROR_BUFFER_SIZE];

// Context structure for YAML processing
typedef struct {
    VM *pVM;
    yaml_document_t *pDocument;
    int depth;
} yaml_context_t;

// Forward declarations
static void ring_yaml_node_to_list_recursive(yaml_context_t *ctx, List *pList, int nNodeId);
static void format_parse_error(yaml_parser_t *pParser);

/**
 * Garbage collection callback for freeing YAML documents
 * @param pState Ring state pointer
 * @param pPointer Pointer to the YAML document to free
 */
void ring_yaml_free_document_gc(void *pState, void *pPointer) {
    yaml_document_t *pDocument = (yaml_document_t *) pPointer;
    if (pDocument) {
        yaml_document_delete(pDocument); 
        ring_state_free(pState, pPointer);
    }
}

/**
 * Set an error message in the thread-local error buffer
 * @param format Format string for the error message
 * @param ... Variable arguments for the format string
 */
static void set_error(const char *format, ...) {
    va_list args;
    va_start(args, format);
    vsnprintf(g_szYamlError, sizeof(g_szYamlError), format, args);
    va_end(args);
}

/**
 * Format a YAML parser error message with location information
 * @param pParser Pointer to the YAML parser that encountered the error
 */
static void format_parse_error(yaml_parser_t *pParser) {
    const char *problem = pParser->problem ? pParser->problem : "Unknown error";
    set_error("Parse error: %.200s at line %d, column %d",
              problem,
              (int)pParser->problem_mark.line + 1,
              (int)pParser->problem_mark.column + 1);
}

/**
 * Create and initialize a YAML parser
 * @param pVM Pointer to the Ring virtual machine
 * @return Pointer to the initialized parser, or NULL if allocation failed
 */
static yaml_parser_t *create_parser(VM *pVM) {
    yaml_parser_t *pParser = (yaml_parser_t *) ring_state_malloc(pVM->pRingState, sizeof(yaml_parser_t));
    if (pParser) {
        yaml_parser_initialize(pParser);
    }
    return pParser;
}

/**
 * Create a YAML document structure
 * @param pVM Pointer to the Ring virtual machine
 * @return Pointer to the allocated document structure
 */
static yaml_document_t *create_document(VM *pVM) {
    return (yaml_document_t *) ring_state_malloc(pVM->pRingState, sizeof(yaml_document_t));
}

/**
 * Parse YAML content using an initialized parser
 * @param pVM Pointer to the Ring virtual machine
 * @param pParser Pointer to the initialized YAML parser
 * @return Pointer to the parsed document, or NULL if parsing failed
 */
static yaml_document_t *parse_yaml_from_parser(VM *pVM, yaml_parser_t *pParser) {
    yaml_document_t *pDocument = create_document(pVM);
    if (!pDocument) {
        set_error("Memory allocation failed for document");
        return NULL;
    }
    
    // Load the YAML document
    if (!yaml_parser_load(pParser, pDocument)) {
        format_parse_error(pParser);
        ring_state_free(pVM->pRingState, pDocument);
        return NULL;
    }
    
    // Clear any previous error
    g_szYamlError[0] = '\0';
    return pDocument;
}

/**
 * Check if a string represents a numeric value
 * @param value The string to check
 * @param length Length of the string
 * @param result Pointer to store the parsed numeric value
 * @return 1 if the string is numeric, 0 otherwise
 */
static int is_numeric_string(const char *value, size_t length, double *result) {
    if (length >= MAX_NUMBER_LEN) return 0;
    
    char buffer[MAX_NUMBER_LEN + 1];
    char *endptr;
    
    // Create a null-terminated copy of the string
    memcpy(buffer, value, length);
    buffer[length] = '\0';
    
    // Try to convert to double
    *result = strtod(buffer, &endptr);
    
    // Check if the entire string was consumed
    return (*endptr == '\0' && endptr != buffer);
}

/**
 * Check if a string represents a boolean value
 * @param value The string to check
 * @param length Length of the string
 * @param result Pointer to store the boolean value (1 for true, 0 for false)
 * @return 1 if the string is boolean, 0 otherwise
 */
static int is_boolean_string(const char *value, size_t length, int *result) {
    if (length == (sizeof("true") - 1) && memcmp(value, "true", sizeof("true") - 1) == 0) {
        *result = 1;
        return 1;
    }
    if (length == (sizeof("false") - 1) && memcmp(value, "false", sizeof("false") - 1) == 0) {
        *result = 0;
        return 1;
    }
    return 0;
}

/**
 * Check if a string represents a null value
 * @param value The string to check
 * @param length Length of the string
 * @return 1 if the string represents null, 0 otherwise
 */
static int is_null_string(const char *value, size_t length) {
    // Check for "null" or "~" (YAML null representations)
    return (length == (sizeof("null") - 1) && memcmp(value, "null", sizeof("null") - 1) == 0) ||
           (length == 1 && value[0] == '~');
}

/**
 * Convert a YAML scalar value to the appropriate Ring type and add to a list
 * @param ctx Pointer to the YAML context
 * @param pList Pointer to the Ring list to add the value to
 * @param value The scalar value string
 * @param length Length of the scalar value
 */
static void convert_scalar_value(yaml_context_t *ctx, List *pList, const char *value, size_t length) {
    double numeric_value;
    int boolean_value;
    
    // Check for null or empty string
    if (length == 0 || is_null_string(value, length)) {
        ring_list_addstring_gc(ctx->pVM->pRingState, pList, "");
    } 
    // Check for boolean
    else if (is_boolean_string(value, length, &boolean_value)) {
        ring_list_addint_gc(ctx->pVM->pRingState, pList, boolean_value);
    } 
    // Check for numeric
    else if (is_numeric_string(value, length, &numeric_value)) {
        ring_list_adddouble_gc(ctx->pVM->pRingState, pList, numeric_value);
    } 
    // Default to string
    else {
        ring_list_addstring2_gc(ctx->pVM->pRingState, pList, value, length);
    }
}

/**
 * Process a YAML sequence node and convert it to a Ring list
 * @param ctx Pointer to the YAML context
 * @param pList Pointer to the parent Ring list
 * @param pNode Pointer to the YAML sequence node
 */
static void process_sequence_node(yaml_context_t *ctx, List *pList, yaml_node_t *pNode) {
    // Create a new list for the sequence
    List *pNewList = ring_list_newlist_gc(ctx->pVM->pRingState, pList);
    
    // Process each item in the sequence
    yaml_node_item_t *pItem;
    for (pItem = pNode->data.sequence.items.start; pItem < pNode->data.sequence.items.top; pItem++) {
        ring_yaml_node_to_list_recursive(ctx, pNewList, *pItem);
    }
}

/**
 * Check if a node is a YAML merge key ("<<")
 * @param pKeyNode Pointer to the key node to check
 * @return 1 if the node is a merge key, 0 otherwise
 */
static int is_merge_key(yaml_node_t *pKeyNode) {
    return pKeyNode &&
           pKeyNode->type == YAML_SCALAR_NODE &&
           pKeyNode->data.scalar.length == 2 &&
           memcmp(pKeyNode->data.scalar.value, "<<", 2) == 0;
}

/**
 * Add all key-value pairs from a YAML mapping node to a Ring list
 * @param ctx Pointer to the YAML context
 * @param pList Pointer to the Ring list to add pairs to
 * @param pMapNode Pointer to the YAML mapping node
 */
static void add_map_pairs_to_list(yaml_context_t *ctx, List *pList, yaml_node_t *pMapNode) {
    if (!pMapNode || pMapNode->type != YAML_MAPPING_NODE) {
        return;
    }
    
    // Process each key-value pair in the mapping
    yaml_node_pair_t *pPair;
    for (pPair = pMapNode->data.mapping.pairs.start; pPair < pMapNode->data.mapping.pairs.top; pPair++) {
        List *pMapItem = ring_list_newlist_gc(ctx->pVM->pRingState, pList);
        ring_yaml_node_to_list_recursive(ctx, pMapItem, pPair->key);
        ring_yaml_node_to_list_recursive(ctx, pMapItem, pPair->value);
    }
}

/**
 * Process merge keys in a YAML mapping node
 * @param ctx Pointer to the YAML context
 * @param pList Pointer to the Ring list to add merged content to
 * @param pNode Pointer to the YAML mapping node
 */
static void process_merge_keys(yaml_context_t *ctx, List *pList, yaml_node_t *pNode) {
    yaml_node_pair_t *pPair;
    
    // Look for merge keys ("<<")
    for (pPair = pNode->data.mapping.pairs.start; pPair < pNode->data.mapping.pairs.top; pPair++) {
        yaml_node_t *pKeyNode = yaml_document_get_node(ctx->pDocument, pPair->key);
        if (is_merge_key(pKeyNode)) {
            yaml_node_t *pValueNode = yaml_document_get_node(ctx->pDocument, pPair->value);
            if (!pValueNode) continue;
            
            // Handle single mapping merge
            if (pValueNode->type == YAML_MAPPING_NODE) {
                add_map_pairs_to_list(ctx, pList, pValueNode);
            } 
            // Handle sequence of mappings merge
            else if (pValueNode->type == YAML_SEQUENCE_NODE) {
                yaml_node_item_t *pItem;
                for (pItem = pValueNode->data.sequence.items.start; pItem < pValueNode->data.sequence.items.top; pItem++) {
                    yaml_node_t *pMergeNode = yaml_document_get_node(ctx->pDocument, *pItem);
                    add_map_pairs_to_list(ctx, pList, pMergeNode);
                }
            }
        }
    }
}

/**
 * Process regular (non-merge) key-value pairs in a YAML mapping node
 * @param ctx Pointer to the YAML context
 * @param pList Pointer to the Ring list to add pairs to
 * @param pNode Pointer to the YAML mapping node
 */
static void process_regular_pairs(yaml_context_t *ctx, List *pList, yaml_node_t *pNode) {
    yaml_node_pair_t *pPair;
    
    // Process each key-value pair that is not a merge key
    for (pPair = pNode->data.mapping.pairs.start; pPair < pNode->data.mapping.pairs.top; pPair++) {
        yaml_node_t *pKeyNode = yaml_document_get_node(ctx->pDocument, pPair->key);
        if (!is_merge_key(pKeyNode)) {
            List *pMapItem = ring_list_newlist_gc(ctx->pVM->pRingState, pList);
            ring_yaml_node_to_list_recursive(ctx, pMapItem, pPair->key);
            ring_yaml_node_to_list_recursive(ctx, pMapItem, pPair->value);
        }
    }
}

/**
 * Process a YAML mapping node and convert it to a Ring list
 * @param ctx Pointer to the YAML context
 * @param pList Pointer to the parent Ring list
 * @param pNode Pointer to the YAML mapping node
 */
static void process_mapping_node(yaml_context_t *ctx, List *pList, yaml_node_t *pNode) {
    // Create a new list for the mapping
    List *pNewList = ring_list_newlist_gc(ctx->pVM->pRingState, pList);
    
    // First process any merge keys
    process_merge_keys(ctx, pNewList, pNode);
    // Then process regular key-value pairs
    process_regular_pairs(ctx, pNewList, pNode);
}

/**
 * Recursively convert a YAML node to a Ring list structure
 * @param ctx Pointer to the YAML context
 * @param pList Pointer to the Ring list to add content to
 * @param nNodeId ID of the YAML node to process
 */
static void ring_yaml_node_to_list_recursive(yaml_context_t *ctx, List *pList, int nNodeId) {
    yaml_node_t *pNode = yaml_document_get_node(ctx->pDocument, nNodeId);
    if (!pNode || ctx->depth > MAX_RECURSION_DEPTH) {
        return;
    }
    
    ctx->depth++;
    
    // Process based on node type
    switch (pNode->type) {
        case YAML_SCALAR_NODE:
            convert_scalar_value(ctx, pList, (const char *) pNode->data.scalar.value, pNode->data.scalar.length);
            break;
        case YAML_SEQUENCE_NODE:
            process_sequence_node(ctx, pList, pNode);
            break;
        case YAML_MAPPING_NODE:
            process_mapping_node(ctx, pList, pNode);
            break;
        default:
            break;
    }
    
    ctx->depth--;
}

/**
 * Parse a YAML file and return a document pointer
 * Ring function: yaml_parse_file(filename)
 */
RING_FUNC(ring_yaml_parse_file) {
    VM *pVM = (VM *) pPointer;
    yaml_document_t *pDocument = NULL;
    yaml_parser_t *pParser = NULL;
    FILE *pFile = NULL;
    
    // Check parameters
    if (RING_API_PARACOUNT != 1 || !RING_API_ISSTRING(1)) {
        RING_API_ERROR(RING_API_MISS1PARA);
        return;
    }
    
    const char *cFileName = RING_API_GETSTRING(1);
    
    // Open the file
    pFile = fopen(cFileName, "rb");
    if (!pFile) {
        set_error("Failed to open file: %.200s", cFileName);
        goto cleanup;
    }
    
    // Check file size
    fseek(pFile, 0, SEEK_END);
    long file_size = ftell(pFile);
    fseek(pFile, 0, SEEK_SET);
    if (file_size > MAX_YAML_SIZE) {
        set_error("File too large: %ld bytes (max: %d)", file_size, MAX_YAML_SIZE);
        goto cleanup;
    }
    
    // Create and configure parser
    pParser = create_parser(pVM);
    if (!pParser) {
        set_error("Memory allocation failed for parser");
        goto cleanup;
    }
    yaml_parser_set_input_file(pParser, pFile);
    
    // Parse the YAML
    pDocument = parse_yaml_from_parser(pVM, pParser);
    
cleanup:
    // Clean up resources
    if (pParser) {
        yaml_parser_delete(pParser);
        ring_state_free(pVM->pRingState, pParser);
    }
    if (pFile) {
        fclose(pFile);
    }
    
    // Return result
    if (pDocument) {
        RING_API_RETMANAGEDCPOINTER(pDocument, RING_YAML_DOCUMENT, ring_yaml_free_document_gc);
    } else {
        RING_API_RETSTRING("");
    }
}

/**
 * Parse a YAML string and return a document pointer
 * Ring function: yaml_parse(yaml_string)
 */
RING_FUNC(ring_yaml_parse) {
    VM *pVM = (VM *) pPointer;
    yaml_document_t *pDocument = NULL;
    yaml_parser_t *pParser = NULL;
    
    // Check parameters
    if (RING_API_PARACOUNT != 1 || !RING_API_ISSTRING(1)) {
        RING_API_ERROR(RING_API_MISS1PARA);
        return;
    }
    
    const unsigned char *pYAMLString = (const unsigned char *) RING_API_GETSTRING(1);
    size_t nSize = RING_API_GETSTRINGSIZE(1);
    
    // Check input size
    if (nSize > MAX_YAML_SIZE) {
        set_error("YAML input too large: %zu bytes (max: %d)", nSize, MAX_YAML_SIZE);
        goto cleanup;
    }
    
    // Create and configure parser
    pParser = create_parser(pVM);
    if (!pParser) {
        set_error("Memory allocation failed for parser");
        goto cleanup;
    }
    yaml_parser_set_input_string(pParser, pYAMLString, nSize);
    
    // Parse the YAML
    pDocument = parse_yaml_from_parser(pVM, pParser);
    
cleanup:
    // Clean up resources
    if (pParser) {
        yaml_parser_delete(pParser);
        ring_state_free(pVM->pRingState, pParser);
    }
    
    // Return result
    if (pDocument) {
        RING_API_RETMANAGEDCPOINTER(pDocument, RING_YAML_DOCUMENT, ring_yaml_free_document_gc);
    } else {
        RING_API_RETSTRING("");
    }
}

/**
 * Convert a YAML document to a Ring list structure
 * Ring function: yaml2list(document)
 */
RING_FUNC(ring_yaml2list) {
    // Check parameters
    if (RING_API_PARACOUNT != 1 || !RING_API_ISCPOINTER(1)) {
        RING_API_ERROR(RING_API_MISS1PARA);
        return;
    }
    
    // Get the document
    yaml_document_t *pDocument = (yaml_document_t *) RING_API_GETCPOINTER(1, RING_YAML_DOCUMENT);
    if (!pDocument) {
        RING_API_ERROR(RING_API_NULLPOINTER);
        return;
    }
    
    // Get the root node
    yaml_node_t *pRootNode = yaml_document_get_root_node(pDocument);
    List *pRingList = RING_API_NEWLIST;
    
    if (pRootNode) {
        // Create context and process the document
        yaml_context_t ctx = {(VM *) pPointer, pDocument, 0};
        int root_id = (pRootNode - pDocument->nodes.start) + 1;
        ring_yaml_node_to_list_recursive(&ctx, pRingList, root_id);
        
        // If the root is a single list, return it directly
        if (ring_list_getsize(pRingList) == 1 && ring_list_islist(pRingList, 1)) {
            RING_API_RETLIST(ring_list_getlist(pRingList, 1));
        } else {
            RING_API_RETLIST(pRingList);
        }
    } else {
        // Empty document
        RING_API_RETLIST(pRingList);
    }
}

/**
 * Get the last error message from YAML parsing
 * Ring function: yaml_lasterror()
 */
RING_FUNC(ring_yaml_lasterror) {
    if (RING_API_PARACOUNT != 0) {
        RING_API_ERROR(RING_API_BADPARACOUNT);
        return;
    }
    RING_API_RETSTRING(g_szYamlError);
}

/**
 * Get the version string of the libyaml library
 * Ring function: yaml_version()
 */
RING_FUNC(ring_yaml_get_version) {
    if (RING_API_PARACOUNT != 0) {
        RING_API_ERROR(RING_API_BADPARACOUNT);
        return;
    }
    RING_API_RETSTRING(yaml_get_version_string());
}

/**
 * Initialize the Ring YAML library
 * Registers all functions
 */
RING_LIBINIT {
    RING_API_REGISTER("yaml_parse_file", ring_yaml_parse_file);
    RING_API_REGISTER("yaml_parse", ring_yaml_parse);
    RING_API_REGISTER("yaml2list", ring_yaml2list);
    RING_API_REGISTER("yaml_lasterror", ring_yaml_lasterror);
    RING_API_REGISTER("yaml_version", ring_yaml_get_version);
}