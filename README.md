# Drag-DropDownload
In this project I will be experimenting with Apple's Drag and Drop API and using it along with other APIs including but not limited to URLSession to create a drag and drop interface to download content from the web. 

v1.0 - January 13th 2019
- Populating a UITableView with simple model class and then using UITableViewDragDelegate to get the ball rolling. 
- Making a UIView a drop destination for the drag items using UIDropInteractionDelegate.
- Counting the number of items dropped on the destination view / and using UIDropInteractionDelegate methods. 

UPDATE: January 20th 2019 
- Populated a table view with podcasts from iTunes Search API
- Fetched the podcast collection name, feedURL as well as the podcast artwork.
- set up a class for the model and used Codable, NSItemProviderWriting and NSItemProviderReading to create a custom item provider.Several Apple provided classes already conform to these protocols such as UIImage, UIColor, NSURL, NSAttributedString and NSString. However, in order to create a custom item provider wrapper for your own model class you need to conform to NSItemProviderWriting and NSItemProviderReading. 
- We are sending our model object as 'KUTTypeData' by first encoding it to JSON (implemented in NSItemProviderWriting method) and then decoding it back to the model type (implemented in NSItemProviderReading method). For this encoding and decoding we are using Codable. 
When creating drag item, we are using item provider which is constructed by using the object of the model class 
        
        let podcastItem = PodcastModelData(collectionName: collectionName, feedURL: feedUrl, artworkURL100: artworkurl)
        let itemProvider = NSItemProvider(object: podcastItem)
        let dragItem = UIDragItem(itemProvider: itemProvider)

Coming up next: 
- Animations 
- Switching to next view controller and downloading podcast episode
