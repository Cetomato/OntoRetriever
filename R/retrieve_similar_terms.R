#' Retrieve Similar Terms from HPO or OAE
#'
#' This function uses the Python FAISS library to retrieve similar terms from ontologies based on mxbai-embed-large text embeddings.
#' @param query A character string representing the query word
#' @param k The number of similar terms to retrieve.
#' @return A data frame containing the HPO term IDs, names, and distances.
#' @import reticulate
#' @export
#' @examples
#' \dontrun{
#' # Example: Retrieve similar terms for the query "irritability"
#' library(OntoRetriever)
#' retrieve_similar_terms("irritability", onto = 'HPO', k = 3)
#' retrieve_similar_terms("irritability", onto = 'OAE', k = 3)
#' retrieve_similar_terms("tired", onto = 'HPO', k = 3)
#' retrieve_similar_terms("swelling at the injection site", onto = 'HPO',k = 3)
#' }
#'
retrieve_similar_terms <- function(query, onto = 'OAE', k = 3) {
  # Find the path to the Python script within the package
  # python_script_path <- system.file("python", "hpo_retriever.py", package = "HPOretriever")
  # Source the Python script using reticulate
  # reticulate::source_python(python_script_path)
  python_script_path <- "/home/wangzg/Nutstore Files/Real_time/LLM/16_ontology_mapping/onto_retriever.py"
  reticulate::source_python(python_script_path)

  # pythonr <- system.file("extdata", "hpo_retriever.rds", package = "HPOretriever")
  # pythonr_c <- readRDS(pythonr)
  # reticulate::py_run_string(pythonr_c)

  # Find the path to the pkl file within the package
  hpo_pkl_file_path <- system.file("extdata", "HPO_embed_db.pkl", package = "OntoRetriever")
  oae_pkl_file_path <- system.file("extdata", "OAE_embed_db_new.pkl", package = "OntoRetriever")

  # Load the HPO embedding database in Python
  reticulate::py$load_hpo_embedding_db(hpo_pkl_file_path)
  reticulate::py$load_oae_embedding_db(oae_pkl_file_path)

  # Call the Python function
  # reticulate::py$retrieve_similar_terms(query='headache', onto='HPO', k=as.integer(3))
  result <- reticulate::py$retrieve_similar_terms(query, onto, as.integer(k))

  # Convert the Python list of tuples to an R data frame
  similar_terms_df <- do.call(rbind, lapply(result, function(x)
    data.frame(
      ID = x[[1]],
      Name = x[[2]],
      Distance = x[[3]]
    )))

  return(similar_terms_df)
}
# retrieve_similar_terms(query='headache', onto='HPO', k=as.integer(3))
# retrieve_similar_terms(query='headache', onto='OAE', k=as.integer(3))
