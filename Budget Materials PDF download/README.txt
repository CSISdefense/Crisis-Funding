INSTRUCTIONS FOR USING AUTOMATIC BUDGET DOWNLOAD SCRIPT (DownloadPDFs.R)
L.Lipsey for DIIG - April 2016

The script will automatically scan every page listed in pagelist.txt, find all the PDFs linked on thise page, and download any that we don't already have to the folder "G:/Defense Budget Documents/AutoDownloaded Archive". It creates sub-folders there to organize the PDFs, based on which webpage the PDF came from. 

The comptroller folder is going to look disorganized - that's because the comptroller's *website* is disorganized, and I didn't find an easy way to reorganize the files from it.  Similarly, the Air Force names its budget PDFs with unhelpful sequential numbers instead of document titles.  I didn't attempt to rename them to anything more useful.


TO USE:


1. ADD URLS FOR PAGES CONTAINING BUDGET PDF LINKS TO pagelist.txt

The file pagelist.txt holds all the URLs (web addresses) for pages containing budget PDF links. Copy the web address for any additional webpages you want to scan, add them to that list, and save the text file. The script should recognize anything from the Comptroller, Navy, or Air Force site and categorize it correctly.  Files from other sites will be added to the "MiscOther" folder.  Army is a special case, explained below. 

Also, the Air Force made a "current year" page instead of a FY17 page.  Presumably they'll create a FY17 page when they put FY18 stuff on the "current year" page.  We should probably rename the "AirForce/Current" folder on the G drive to "AirForce/17" before running the script to update for FY18.  It will automatically create a new "Current" folder with the FY18 documents if the Air Force organizes it that way again.



2. MANUALLY DOWNLOAD HTML CODE POINTING TO ARMY BUDGET PDFS

The Army puts budget materials for different fiscal years in a javascript selector on one page,
(http://www.asafm.army.mil/offices/BU/BudgetMat.aspx) instead of using a separate page for each fiscal year.  That's a problem for us, as it prevents us from automatically scanning for PDFs from previous fiscal years.  To get around that, we'll need to locally save a html file with links to the materials from every fiscal year, then scan that.  Here's what you need to do:

	- Open http://www.asafm.army.mil/Document.aspx in a browser window.
	- Choose "Army Budget (BU)" from the first drop-down box (Office).
	- Choose "Budget Materials" from the second drop-down box (Category).
	- Right click on a blank area of the page, and click View Page Source.
	- Your browser opens a new tab and tells you to confirm resubmission.  Click refresh.
	- Right click on a blank area and click Save As.
	- Save the page in this folder ("Budget Materials PDF Download" on K:/Development/Budget)
	  with the default name and type ("view-source_www.asafm.army.mil_Document.aspx.html")
	  Don't change the name, or the script won't find it.
	
The script will read this file and extract the web locations for all the Army budget PDFs from it.



3. RUN THE SCRIPT

Open DownloadPDFs.R - you will need R installed.  I used R version _____ and RStudio version 0.99.491 to write it, but it should work with any recent version.  You might need to install some of the packages it uses by typing: 
=======
Open DownloadPDFs.R - you will need R installed.  I used R version 3.2.3 and RStudio version 0.99.491 to write it, but it should work with any recent version.  You might need to install some of the packages it uses by typing: 
  install.packages("packagename")
in the console.  Packages it uses are "stringr", "httr", and "RCurl".

Highlight the entire script and run it.  This took about 5 hours to download 5400 PDFs the first time I ran it.  But the script will only download PDFs we don't already have, so it shouldn't take that long for an update.



4. ERROR RECOVERY

If the script encounters an error while trying to download a file, you can simply run the "DOWNLOAD FILES" section again.  Or, if R crashed, run the whole script again.

The script checks whether we already have a file before trying to download it, so it should quickly catch back up to the point where downloading left off.  However, you might have gotten an incomplete or corrupted version of the file that caused the error.  Check the console to see which file it choked on, copy that URL, and download the file manually to make sure you get a complete and uncorrupted version.

KNOWN BUG:
Sometimes the script will download a broken PDF, of file size 25 bytes, but with the correct name and stored in the correct location.  I don't know why this happens, and it doesn't happen to the same files consistently.  Simply running the script again will overwrite the broken file with the real one.



5. UPDATE THE PDF ARCHIVE

Open Adobe Acrobat Pro, which most computers seem to already have.  Navigate to Tools > Document Processing > Full Text Index with Catalog.  You want to open index, then point it at "Complete Archive.pdx" in "G:/Defense Budget Documents/AutoDownloaded Archive".  Update the archive by selecting the folder for each source (Army, Navy, AirForce, Comptroller), which will include all PDFs in the subfolders.  Choose build archive (not rebuild, which will take longer).  This will take some time to run, possibly even overnight.