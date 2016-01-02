# AzStoragePodcast

Generate an RSS feed for media files stored in Azure Storage.

## Setup

 - Follow the steps on
   [the Azure website](https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/)
   to set up the Powershell extensions for Azure. Make sure to log in
   to your account at this stage.
 - Create an Azure storage account (either with Powershell or via the
   web based UI) with the `Classic` deployment method.
 - Create a `container` in the storage account with the `blob` access
   type. (*blob* will make the files public, but will not advertise
   the URL).
 - Get [Azure Storage Explorer](http://storageexplorer.com/) to use as
   a GUI to transfer files to the storage container.

## Usage

 - Upload any media files (`.mp3` or `.m4a`) to your specified
   container with *Storage Explorer*.
 - Run the included Powershell script like the following:

    > .\Generate-PodcastFeed.ps1 -StorageAccount myaccountname -Container mycontainername

## Potential future enhancements:

 - Add feed icon
 - Custom title
 - Better per-item titles
 - Automatically create the storage account and container.
 - Sync a local directory to storage without the need for something like storage explorer.
 - Support alternate means of ordering items in the feed (such as alpha, date/time, etc)
