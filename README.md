# BarcodeBookScannerApp

The app can scan a barcode (ISBN) from a book, and show information about it. 
Besides seeing info about the scanned book, you can view different bookshelf downloaded from the 'Google Books API'. So you can add a book to a bookshelf on a browser and see it in the app. 

A scanned book can be added to all available bookshelfs, but beware! Some bookshelf are read-only and can't have books added to them. When a book is scanned it is added to CoreData.

The app uses OAuth 2.0 to sign in. When a user signs in, a user is added to a Firebase database, when the user scans books, that user will be asigned the scanned book. So when the bookshelf collectionView loads, it downloads the previously added books and compares them to the books in CoreData, and adds any books from the database to CoreData, if needed. 
Books can be removed from the bookshelfs.
