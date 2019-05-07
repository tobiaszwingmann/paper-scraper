library(XML)
library(rjson)
library(tidyverse)
library(httr)

# Working directory
path <- "C:/tmp/"

# Read Crawling JSON and flatten object

results_flat <- fromJSON(file = paste0(path,"dataset_SpWnweKAALEB7W4BE.json")) %>% 
  unlist() %>% 
  tibble(key = names(.), value = (.)) %>% 
  select(-1)

# Extract PDF URLs

result_pdfs <- results_flat %>% 
  filter(key=="organicResults.url")

# Extract File names

result_pdfs$filename <- basename(result_pdfs$value) 
result_pdfs$filename <- str_remove(result_pdfs$filename, ".*\\?.*=") # For PHP requests


# Loop through document


for (i in 1:nrow(result_pdfs)) {
  
    url <- result_pdfs$value[i]
    filename <- result_pdfs$filename[i]
    
    tryCatch(
      GET(url, write_disk(paste0(path,filename), overwrite=F), timeout(240)), 
      warning = function(w) w, 
      error = function(e) e)
    
  
}

# Write Meta information
write_csv2(x=result_pdfs, path=paste0(path,"meta-data.csv" ))
