#' Map Text to HPO Terms
#'
#' This function extracts Adverse Reaction terms from input text using the Ollama API and retrieves similar terms from the HPO ontology using the Python FAISS library.
#' @param ae_text A character string representing the text containing Adverse Reactions.
#' @param k The number of similar terms to retrieve for each AE term.
#' @return A list of mappings from AE terms to HPO terms.
#' @import reticulate
#' @export
#' @examples
#' \dontrun{
#' # Example: Map AE terms to HPO terms
#' library(OntoRetriever)

#' map_text_to_hpo("The most commonly reported reactions were pain at the injection site and headache.", k = 3)
#' map_text_to_hpo(
#'   "The most commonly reported solicited local and systemic adverse reactions in pregnant individuals (≥10%)
#'   were pain at the injection site (40.6%), headache (31.0%), muscle pain (26.5%), and nausea (20.0%). (6.1)
#'   The most commonly reported solicited local and systemic adverse reactions in individuals 60 years of age
#'   and older (≥10%) were fatigue (15.5%), headache (12.8%), pain at the injection site (10.5%), and muscle
#'   pain (10.1%).",
#'   k = 3
#' )
#' }
#'
map_text_to_hpo <- function(ae_text, k = 3) {
  # Find the path to the Python script within the package
  python_script_path <- system.file("python", "onto_retriever.py", package = "OntoRetriever")
  # Source the Python script using reticulate
  reticulate::source_python(python_script_path)

  # pythonr <- system.file("extdata", "hpo_retriever.rds", package = "OntoRetriever")
  # pythonr_c <- readRDS(pythonr)
  # reticulate::py_run_string(pythonr_c)


  # Find the path to the pkl file within the package
  hpo_pkl_file_path <- system.file("extdata", "HPO_embed_db.pkl", package = "HPOretriever")

  # Load the HPO embedding database in Python
  py$load_hpo_embedding_db(hpo_pkl_file_path)

  # Call the Python function to extract AE words
  # ae_text = 'The most commonly reported reactions were pain at the injection site and headache.'
  ae_words <- py$get_ae_words(ae_text)

  # Initialize an empty data frame to store the mappings
  hpo_mappings_df <- data.frame(
    word = character(),
    ID = character(),
    Name = character(),
    Distance = numeric(),
    stringsAsFactors = FALSE
  )

  # Retrieve similar terms for each AE word
  for (word in ae_words) {
    # word = 'headache'
    # similar_terms <- py$retrieve_similar_terms(query='headache', onto='HPO', k=as.integer(3))
    similar_terms <- py$retrieve_similar_terms(query=word, onto = 'HPO', k=as.integer(k))

    # If similar terms are found, append them to the data frame
    if (length(similar_terms) > 0) {
      word_df <- data.frame(
        word = rep(word, k),
        ID = sapply(similar_terms, function(x)
          x[[1]]),
        Name = sapply(similar_terms, function(x)
          x[[2]]),
        Distance = sapply(similar_terms, function(x)
          x[[3]]),
        stringsAsFactors = FALSE
      )
      hpo_mappings_df <- rbind(hpo_mappings_df, word_df)
    }
  }

  return(hpo_mappings_df)
}

# map_text_to_hpo("The most commonly reported reactions were pain at the injection site and headache.", k = 3)
