import faiss
import numpy as np
import ollama
import pickle
import os
import requests

# For HPO
# Function to load the HPO embedding database
def load_hpo_embedding_db(hpo_pkl_file_path): 
    # Load the HPO embedding database from the file
    with open(hpo_pkl_file_path, 'rb') as f:
        hpo_embed_db = pickle.load(f)
    
    # Assign global variables for later use
    global hpo_terms, hpo_index, hpo_embeddings
    hpo_terms = hpo_embed_db["hpo_terms"]
    hpo_embeddings = hpo_embed_db["hpo_embeddings"]
    hpo_index = faiss.IndexFlatL2(hpo_embeddings.shape[1])
    hpo_index.add(hpo_embeddings)
    # return hpo_embed_db

# For OAE
# Function to load the OAE embedding database
def load_oae_embedding_db(oae_pkl_file_path): 
    # Load the HPO embedding database from the file
    with open(oae_pkl_file_path, 'rb') as f:
        oae_embed_db = pickle.load(f)
    
    # Assign global variables for later use
    global oae_terms, oae_index, oae_embeddings
    oae_terms = oae_embed_db["oae_terms"]
    oae_embeddings = oae_embed_db["oae_embeddings"]
    oae_index = faiss.IndexFlatL2(oae_embeddings.shape[1])
    oae_index.add(oae_embeddings)
    # return oae_embed_db

# Function for retrieve_similar_terms
def retrieve_similar_terms(query, onto='HPO', k=3):
    # query_vec = np.array(list(ollama.embeddings(model='mxbai-embed-large', prompt=query).values())[0], dtype=np.float32)
    response = ollama.embeddings(model='mxbai-embed-large', prompt=query)
    # ollama 0.3.9
    query_vec = np.array(list(response.values())[0], dtype=np.float32)
    # ollama new version
    # query_vec = np.array(response.embedding, dtype=np.float32)
    query_vec = query_vec.reshape(1, -1)

    if onto == 'HPO':
        distances, indices = hpo_index.search(query_vec, k)
        similar_terms = [(list(hpo_terms.keys())[i], list(hpo_terms.values())[i], distances[0][j]) for j, i in enumerate(indices[0])]
    elif onto == 'OAE':
        distances, indices = oae_index.search(query_vec, k)
        similar_terms = [(list(oae_terms.keys())[i], list(oae_terms.values())[i], distances[0][j]) for j, i in enumerate(indices[0])]
    else:
        raise ValueError("Invalid ontology specified. Use 'HPO' or 'OAE'.")
    
    return similar_terms

# Extract words related to AE
def get_ae_words(ae_text):
    ollama_url = "http://localhost:11434/api/generate"
#   ae_text = "• The most commonly reported solicited local and systemic adverse reactions in pregnant individuals (≥10%) were pain at the injection site (40.6%), headache (31.0%), muscle pain (26.5%), and nausea (20.0%). (6.1) • The most commonly reported solicited local and systemic adverse reactions in individuals 60 years of age and older (≥10%) were fatigue (15.5%), headache (12.8%), pain at the injection site (10.5%), and muscle pain (10.1%). (6.1)"
    get_ae_words_prompt = (
    f"In the text: '{ae_text}', extract all unique Adverse Reaction terms directly, in lowercase, and return them in a single line separated by commas. "
    f"Do not add any extra words, phrases, or explanations; only return the terms themselves. Do not include any introductory pharases like 'Here are the unique Adverse Reaction terms directly extracted from the input text:'"
    f"\n\nExample:\n"
    f"Input text: '• Most common local adverse reactions in ≥20% of subjects were pain, redness, and swelling at the injection site. (6.1) • Most common general adverse events in ≥20% of subjects were fatigue, headache, myalgia, gastrointestinal symptoms, and arthralgia. (6.1)'"
    f"\nOutput text: 'pain, redness, swelling at the injection site, fatigue, headache, myalgia, gastrointestinal symptoms, arthralgia'"
)

    payload = {
        "model": "llama3.1",
        "prompt": get_ae_words_prompt,
        "stream": False
    }

    response = requests.post(ollama_url, json=payload)

    if response.status_code == 200:
        ae_words = response.json().get('response', '')
        ae_words_list = [word.strip() for word in ae_words.split(',')]
        ae_words_list = list(set(ae_words_list))  # Remove duplicates
        return ae_words_list
    else:
        print("Failed to retrieve AE words. Status code:", response.status_code)
        return []

# hpo_pkl_file_path = "16_ontology_mapping/OntoRetriever/inst/extdata/HPO_embed_db.pkl"
# load_hpo_embedding_db(hpo_pkl_file_path)
# retrieve_similar_terms(query='headache', onto='HPO', k=3)
# oae_pkl_file_path = "16_ontology_mapping/OntoRetriever/inst/extdata/OAE_embed_db_new.pkl"
# load_oae_embedding_db(oae_pkl_file_path)
# retrieve_similar_terms(query='headache', onto='OAE', k=3)
# ae_text = "• The most commonly reported solicited local and systemic adverse reactions in pregnant individuals (≥10%) were pain at the injection site (40.6%), headache (31.0%), muscle pain (26.5%), and nausea (20.0%). (6.1) • The most commonly reported solicited local and systemic adverse reactions in individuals 60 years of age and older (≥10%) were fatigue (15.5%), headache (12.8%), pain at the injection site (10.5%), and muscle pain (10.1%). (6.1)"
# get_ae_words(ae_text)





