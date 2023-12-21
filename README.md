# VoyageVault

VoyageVault is an advanced travel tracking application designed to enhance and record your travel experiences. This README provides a comprehensive guide on the design decisions, technical specifications, testing challenges, and interactions with Version 2 (V2) features of the app.

*Note that this is a copy of the original repository as the original repository has private information not to be shared publicly.

![promotional_poster](Images/Team14.svg)

## Design Decisions
   - To prevent user overload, we stilced to having three tabs; user profile (statistics), history, map. These view are pretty self-explanatory as in the history you can view all placed pins as well as add old pins. In the Map display you can add pins from travels prior to the app, and in the stastics page we have a gamification idea to see how you rank among other users as well as your own personal stats such as most recent travelling timeslot

## Technical Decisions
   - To allow for mulit-user use, we made the choice to use Google Firebase to handle logging in to an account, logging out, signing in/out
   - We've also integrated Apple MapKit to allow users to view pins they have placed on a map view as well as easily add pins through a simple tap or so

## Testing Issues
   - Our testing process involves rigorous UI testing to ensure each element functions as intended, as per the feature list.
   - Backend tests are somewhat limited due to compatibility issues with Firebase.
   - There was a significant effort put into backend testing, however, this was rather a roadblock as the backend testing relied heavily on pulling data from Google Firebase, which caused runtime issues due to there being a limit on the server bandwith.
     - The full *working* test suite can be found on the adding_testing branch
     - Other tests were created to test all ViewModels in terms of synchronous functionality such as sorting, however, this required a pull from Google Firebase that otherwise caused our Google Firebase account to exceed bandwitch limits.
     - We have tried to alter asynchronous waiting times throughout the code, however, this issue was mainly from firebase
       

## V2 Features Guide
### How to Interact with V2 Features:

1. **Onboarding**
   - Upon first opening the app, users will encounter onboarding screens. These currently contain placeholder images and text pending final UI touches.

2. **View Information About Locations Visited**
   - Navigate to the 'History' page. Features include a search bar, hamburger menu, and three viewing options. Users can view detailed information about each location visited, such as date range, placed pins, famous landmarks, and trip photos.

3. **Editing Pins**
   - In the single pin view, users have options to edit the details of their pins.

4. **Deleting a Pin**
   - Similarly, in the single pin view, users can choose to delete a pin.

5. **Viewing all photos from pins**
   - If you navigate towards the bottom of the Statistics page, you will be able to see all of the images you have added to your pins.

6. **Share/Delete Photos**
   - Users can share or remove photos from their personal gallery on the profile page. Long-pressing an image brings up options to share or delete it.

7. **View Total Continents Visited**
   - The profile page includes a feature to view the total number of continents the user has traveled to.

8. **View Total Countries Visited**
   - Users can also see the number of countries they have visited on their profile page.
  
9. **View Total Cities Visited**
    - The profile page provides an overview of the total number of cities visited.

10. **View Most Frequent Travel Time**
    - Users can identify their most frequent travel times throughout the year on their profile page.

11. **Upload Gallery Photo to Pin**
   - When adding or editing a pin, users have the option to upload photos from their phone gallery.

12. **Users can add previous trips to their pins**
   - 

## User Interface
The UI of VoyageVault is currently limited. These aspects are to be finished before the presentation.

## Warnings
Please note that updates in Firebase may not immediately reflect in the app. Sometimes, restarting the app may be necessary to trigger these updates.
