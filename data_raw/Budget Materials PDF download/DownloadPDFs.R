# DOD BUDGET PDFS AUTOMATIC DOWNLOAD PROJECT
# L.Lipsey for DIIG - April 2016

################################################################################
# THIS SCRIPT WILL PREPARE TO DOWNLOAD PDFs FROM A LIST OF DOD WEBSITES
# (pagelist.txt)
#
# - check all websites listed in the pagelist.txt file in this folder
# - find all available PDF files linked on those pages
# - create a logical directory structure for the PDFs within the 
#   "Budget Materials PDF download" directory in this folder
# - download PDFs into appropriate directories
################################################################################

library(stringr)        # for extracting text strings from webpage contents
library(httr)           # for reading html
library(RCurl)          # for downloading

# Save original working directory
originalwd <- getwd()

# Set location for downloads
setwd("G:/Defense Budget Documents/AutoDownloaded Archive")

# Read in URLS from pagelist file
pagelist <- as.character(unlist(read.table(
      "K:/Development/Budget/Budget Materials PDF download/pagelist.txt")))

# Initialize lists for PDF URLs and local save locations
URLsToSave <- vector("character", length = 0)
PathsToSave <- vector("character", length = 0)
errorcount <- 0L


################################################################################
# PDF-FINDING LOOP: 
# Read one URL from the pagelist file and add all PDFs from that page to
# the for-download lists (URLsToSave and PathsToSave)
###############################################################################

print("Building list of PDFs for download - This should take <5 minutes")

for(i in seq_along(pagelist)) {
      
      # read the contents of the webpage into a character variable      
      url <- as.character(pagelist[i])
      html = try(GET(url))
      pdfurl <- vector("character", length = 0)
      
      # If it didn't read correctly, skip this iteration and add to an error
      # counter.  The user will be asked to run the script again if there were
      # any downloading errors.
      if(inherits(html, "try-error")) {
         errorcount <- errorcount + 1
         continue
      }
      
      # build a list of the URLs of all PDFs linked within the read website
      contents = content(html, as="text")
      pdfs <- unlist(str_extract_all(contents,
                    '/[A-Za-z0-9-._~:/?#@!%$&()*+,;=]*?\\.[Pp][Dd][Ff]'))
      
      # Create "from" and "pagename" vectors to determine file structure
      # when saving
      # "from" : which agency produced the PDF
      # "pagename": which page was the PDF found on
      if(grepl("comptroller.defense.gov", url)){
            for(k in seq_along(pdfs)){
                  if(!grepl("www.whitehouse.gov", pdfs[k]) &
                     !grepl("comptroller.defense.gov", pdfs[k])){
                        pdfurl[k] <- paste("http://comptroller.defense.gov",
                                        pdfs[k], sep="")
                  }
                  else{pdfurl[k] <- paste("http:", pdfs[k])}
            }
            from <- "Comptroller"
            pagename <- unlist(strsplit(
                  url,"http://comptroller.defense.gov/BudgetMaterials/"))[2]
            pagename <- unlist(strsplit(pagename, "\\.aspx"))[1]
            if(is.na(pagename)) {pagename <- "MiscOther"}
      }
      
      else if(grepl("saffm.hq.af.mil", url)){
            pdfurl <- paste("http://www.saffm.hq.af.mil", pdfs, sep = "")
            from <- "AirForce"
            pagename <- unlist(strsplit(
                  url, "http://www.saffm.hq.af.mil/budget/pbfy"))[2]
            pagename <- unlist(strsplit(pagename, "\\.asp"))[1]
            if(is.na(pagename)){pagename <- "Current"}
      }
      
      else if(grepl("secnav.navy.mil", url)){
            pdfurl <- paste("http:", pdfs, sep = "")
            from <- "Navy"
            pagename <- unlist(strsplit(url,
                                        "http://www.secnav.navy.mil.*Fiscal-Year-"))[2]
            pagename <- unlist(strsplit(pagename,"\\.aspx"))[1]
      }
      
      else{
            from <- "MiscOther"
            pagename <- character(0)
      }
      if(is.na(pagename)){pagename <- "MiscOther"}
      
      ### Create file structure
      dir.create(from, showWarnings = FALSE)
      if(length(pagename) != 0){dir.create(file.path(from, pagename),
                                           showWarnings = FALSE)}
      
      
      ### Create the individual file name for the PDF as it will be saved
      pdfname <- str_extract(pdfurl, "/[A-Za-z0-9-._~:?#@!%$&()*+,;=]*?\\.[Pp][Dd][Ff]")
      for(i in seq_along(pdfname)){
            pdfname[i] <- unlist(strsplit(pdfname[i], "/"))[2]
            pdfname[i] <- paste("/", pagename, "_", pdfname[i], sep="")
      }
      ### Combine the agency, page, and file names to create the entire filepath
      savepath <- vector("character", length = 0)
      for(j in seq_along(pdfurl)){
            savepath[j] <- paste(from, "/", pagename, pdfname[j],
                                 sep = "")
      }
      
      # rename duplicated savepaths so they don't overwrite
      dupeindex <- duplicated(savepath)
      for(i in seq_along(savepath)){
          if(dupeindex[i]){
              savepath[i] <- gsub('\\.[Pp][Dd][Ff]', '_2.pdf', savepath[i])    
          }
      }
      
      # Add PDF web address to list URLsToSave for download later
      # Add PDF intended local file name to list PathsToSave
      PathsToSave <- append(PathsToSave, savepath)
      URLsToSave <- append(URLsToSave, pdfurl)
}

if(errorcount > 0) { 
      stop("There was a problem connecting to one of the webpages listed.\n
           Try running it again; if it fails check that the URLs in \n
           pagelist.txt are valid and that the websites are online.")}


################################################################################
# READ ARMY PDF LIST FROM A LOCAL FILE
# Special case for the Army, as explained in README.txt
################################################################################

# Read in locally saved file
contents <- paste(readLines(
"K:/Development/Budget/Budget Materials PDF download/view-source_www.asafm.army.mil_Document.aspx.html"),
                  collapse="\n")

# Extract PDF names from local file using regular expressions
pdfs <- unique(unlist(str_extract_all(contents,
                            '/[A-Za-z0-9-._~:/?#@!%$&()*+,;=]*?\\.[Pp][Dd][Ff]')))
# initialize variables used in loop
pagename1 <- vector("character", length = 0)
pagename2 <- vector("character", length = 0)
savepath <- vector("character", length = 0)
from <- "Army"

# Web location of PDF; will be added to list for download
pdfurl <- paste("http:", pdfs, sep = "")

# local file name of PDF, will be added to list for local save location
pdfname <- str_extract(pdfurl, "/[A-Za-z0-9-._~:?#@!%$&()*+,;=]*?\\.[Pp][Dd][Ff]")
for(i in seq_along(pdfname)){
      pdfname[i] <- unlist(strsplit(pdfname[i], "/"))[2]
}

# loop over each Army budget PDF name found in the local file and parse its name
# to determine what year it came from, so it can be saved in a directory
# for that year
for(j in seq_along(pdfs)){
      pagename1[j] <-  unlist(strsplit(pdfs[j], "(?i)/fy"))[2]
      pagename2[j] <- substr(pagename1[j], 1,2)
      if(is.na(pagename2[j])){pagename2[j] <- "17"}
      
      
      savepath[j] <- paste(from, "/", pagename2[j], "/", pagename2[j],
                           "_", pdfname[j], sep = "")
}

# rename duplicated savepaths so they don't overwrite
dupeindex <- duplicated(savepath)
for(i in seq_along(savepath)){
    if(dupeindex[i]){
        savepath[i] <- gsub('\\.[Pp][Dd][Ff]', '_2.pdf', savepath[i])    
    }
}


# add Army PDFs to the list of other PDFs for download, and add their local
# save locations to the list of other local save locations
PathsToSave <- append(PathsToSave, savepath)
URLsToSave <- append(URLsToSave, pdfurl)


### Create file structure for Army
subdirs <- unique(pagename2)
dir.create(from, showWarnings = FALSE)
for(j in seq_along(subdirs)){
      dir.create(file.path(from, subdirs[j]), showWarnings = FALSE)
}

################################################################################
# DOWNLOAD FILES
################################################################################

# loop over all PDF web locations in the URLsToSave list, generated by code 
# above, and save them to local locations in the PathsToSave list.

# If you got an error while downloading, you can start over here to try to get
# any files you missed, as long as R still has the URLsToSave and PathsToSave
# lists in memory.  If it doesn't, you need to run the whole script again.

# The if statement checks that the file already exists before trying to
# download it, and won't overwrite files we already have.  If the file exists
# but is really small (i.e. because of a previous downloading error),
# it will overwrite it.
errorcount <- 0L

for(i in seq_along(URLsToSave)){
      if(!file.exists(PathsToSave[i]) | file.size(PathsToSave[i]) < 3400){
            if(url.exists(URLsToSave[i])){
                  tryCatch({download.file(URLsToSave[i], PathsToSave[i],
                     method = "libcurl", mode="wb")
                     cat(paste("Downloaded Successfully", i, URLsToSave[i],
                               sep = "\n"))},
                     error = function(e){errorcount <- errorcount + 1; e})
            }
      }
      cat(paste("Checked",i,"of",length(URLsToSave), "\n", sep = " "))
}

if(errorcount > 0) {
      print(paste(errorcount, "files had download problems; run the Download
      Files section again to try those again."))
}

################################################################################
# Copy files from the directory structure to the allPDFs folder for use by
# the PDF search tools
################################################################################

copylist <- list.files(path = 
        "G:/Defense Budget Documents/AutoDownloaded Archive/Comptroller",
        full.names = TRUE, recursive = TRUE, include.dirs = FALSE)

copylist <- append(copylist, list.files(path =
        "G:/Defense Budget Documents/AutoDownloaded Archive/Army",
        full.names = TRUE, recursive = TRUE))

copylist <- append(copylist, list.files(path =
        "G:/Defense Budget Documents/AutoDownloaded Archive/Navy",
        full.names = TRUE, recursive = TRUE))

copylist <- append(copylist, list.files(path =
        "G:/Defense Budget Documents/AutoDownloaded Archive/AirForce",
        full.names = TRUE, recursive = TRUE))


destlist <- copylist %>% 
    lapply(strsplit, "/") %>% 
    lapply(unlist) %>%
    lapply(tail, 1) %>% 
    lapply(function(x){
        file.path("G:","Defense Budget Documents", "AutoDownloaded Archive",
                    "allPDFs", x)
    })

cat("\n\n\nCopying files to allPDFs folder\n\n\n")

lapply(copylist, file.copy,
       to = "G:/Defense Budget Documents/AutoDownloaded Archive/allPDFs",
       overwrite = FALSE)


# Cleanup: return to original working directory
setwd(originalwd)