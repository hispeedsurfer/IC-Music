![IC_Music](https://github.com/user-attachments/assets/ff00f477-cc91-4bf3-b1e2-ad40736028f7)

![IC_Music_pl](https://github.com/user-attachments/assets/053089f7-a5ce-454e-a7cb-40d279e388e4)


# IC_Music

IC_Music is a music instructions for fitness training. It is designed to play music from Spotify and to provide information about the current track and the next one in the playlist. It also provides information about the current cycle and the next cycle in the playlist. The app is designed to be used during fitness training, such as indoor cycling (that for IC stands for). It is designed to be easy to use and to provide the information you need to keep your workout on track.



Properties:
- Spotify iOS Sessionmanager.connection for authentication
- Spotify API to determine playlist titels (iOS SDK limeted to 20 items per playlist)
- Have to be online for authentication, can be used offline after
- Tap feature to identify BPM because Spotify "autio feature" is obsolete (deprecated)
- CoreData so save notes and other properties (no cloud data)
- Whole CoreData can be exported and imported for backup possibility
- SwifUI
- Current and next title/cycle instructions/information (ediable)at runtime
- Font size adjustable
- Total playtime of playlist
- preconfigured instructions for different cycle types
- You can use IC_Music side by side with other apps (e.g. Spotify) on an iPad using  Split View (see Screen shots)
- Playlist can be exported to a CSV file
- Play/Pause/Next/Previous/Volume controlled only from Spotify app

## How to use
- select a playlist from your Spotify account
- start the IC_Music app

### Requirements
A Spotify account is required to use this app. You will need to have a Spotify Premium account to use the Spotify API.

### CSV File export
- The app can export the current playlist to a CSV file. The file will contain the title, artist, and BPM of each song in the playlist. The file can be used to import the playlist into excel or other spreadsheet software.

### Export/Import CoreData
- Export: Go to the settings view and tap the export button. The app will create a file that you can save to your iCloud Drive or other cloud storage.
- Import: Go to the settings view and tap the import button. The app will ask you to select the file you want to import. You can only import files the IC_Music app folder (restricted access iOS).




