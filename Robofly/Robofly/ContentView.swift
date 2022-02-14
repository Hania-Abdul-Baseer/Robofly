//
//  ContentView.swift
//  Robofly
//
//  Created by Hania Abdul Baseer on 14/2/2022.
//

/*
 ContentView code for ROBO FLY, a game where the drone flies when the user taps and
user loses if the drone collides with moving obstacles of varying sizes
The score is increased by 1 point, every second the game is running and stops when player loses
User's highscore is stored in the data and is updated everytime the current score exceeds
this highscore
Lastly the user has the option to restart the game
 
This game is compatible with iphone 11 series and onwards.
*/

import SwiftUI

struct ContentView: View{
   let defaults = UserDefaults.standard // Variable to store the default variables obtained from the data storage
   let scoreKey = "scoreKey" // Defining the key to set highScore as a userDefault
   @State private var score = 0.0 // Current score of the user
   @State private var highScore = 0.0 // Highest score of the user, stored in the data
   @State private var dronePosition = CGPoint(x:100,y:100) // Initial position of the drone
   @State private var buildingPosition = CGPoint(x:700,y:300) // Initial position of the building
   @State private var start = false // Variable to indicate whether the game has started, initially set to false
   @State private var isPaused = false // Variable to indicate whether the game is paused, initially set to false
   
   // Timer that will shoot once every 0.1 second
   // This timer is for the downward movement of the drone which will always be the same
   @State var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
   
   // Timer for the movement of the building i.e the difficulty
   // Which will change as the score increases
   @State var timerLevel = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
   
   var body: some View{
       GeometryReader{ geo in
           ZStack{
               // The initial view and contents on the screen before the game starts
               if self.start == false{
                   // Displaying the game title, logo and start button images
                   ZStack{
                       Image("title").resizable().frame(width: 600, height: 600)
                           .position(x: 400,y:150).background(Image("background"))
                       Image("robo").resizable().frame(width: 200, height: 200)
                           .position(x: 400, y:100)
                       // When the user taps on the start button, the game will start
                       Button(action:{self.start = true }, label: {Image("start").resizable()})
                           .frame(width: 100, height: 35).position(x: 400, y: 300)
                       }
               }
               
               // The view and contents while the game is being played
               if self.start == true{
                   
                   // Instantiation of the Drone object, with position: selfPosition
                   Drone()
                       .position(self.dronePosition)
                   
                       // Every 0.1 second that the timer shoots, the gravity function is called
                       .onReceive(self.timer){i in
                           self.gravity() // The gravity fucntion moves the drone downwards by 40 places
                       }
                   
                   // Instantiation of the building object that serve as the obstacles for the moving drone
                   // the building has position: buildingPosition
                   Building()
                       .position(self.buildingPosition)
                   
                       // Every 0.1 second that the timerLevel shoots, the buildingMove function is called
                       .onReceive(self.timerLevel){i in
                               self.buildingMove() //// moves the building forward and control the varying sizes of the building
                       }
                   
                   // Displaying current score of the user on screen
                   Text("\(Int(self.score))")
                       .font(.body)
                       .foregroundColor(Color.white)
                       .position(x: geo.size.width - 100, y: geo.size.height/10)
         
                   // Displaying high score of the user
                   Text("High Score: \(Int(self.highScore))")
                       .font(.body)
                       .foregroundColor(Color.white)
                       .position(x: geo.size.width - 700, y: geo.size.height/10)
                   
                   // Whenever the game is paused (due to collision)
                   // Restart button shows on screen
                   if self.isPaused == true{
                       
                   // Once the user taps on this restart button, the "resume" function is called to resume the game
                       Button(action:{self.resume()}, label: {Image("restart").resizable()})
                           .frame(width: 100, height: 35).position(x: 400, y: 200)
                   }
               }
           }
           // Specifying the width and height of the screen and background color
           .frame(width: geo.size.width, height: geo.size.height)
           .background(Color.black)
           
           // Tap gesture to move the drone upwards by 130 places whenever the user taps the screen
           .gesture(
               TapGesture()
                   .onEnded{
                       withAnimation{
                           if isPaused == false{
                               self.dronePosition.y -= 130
                           }
                       }
                   }
           )
           
           // Everytime the timerLevel shoots, the updateLevel function is called
           .onReceive(timerLevel) {i in
               self.updateLevel() // Function that changes the difficulty of the game based on the user's current score
           }
           
           .onReceive(self.timer) {i in
               self.readHighScore() // Function to read the current highscore stored in the game's data
               score += 0.1 // Score is increased by 1 every 0.1 second of the timer
               self.findingCollision() // Function to check if there's a collision
               
               // If the drone is below the screen boundary, the game is paused
               // +50 to provide leniency by reducing margin of boundary
               if self.dronePosition.y > geo.size.height+50{
                   self.isPaused = true
                   self.pause()
               }
               
               // If the drone is going above the screen max boundary,
               // the position is resetted to the max
               // So the drone can never fly too high, leaving the screen
               if self.dronePosition.y < 0{
                   withAnimation{
                       self.dronePosition.y = 0
                   }
               }
           }
       }
       // the contents and view will span beyond the device's safe areas
       .edgesIgnoringSafeArea(.all)
   }
   
   // Function to update the level/difficulty of the game during the game being played
   func updateLevel(){
       if self.isPaused == false{
           
           // If the user's current score is between 20 and 40, the buildings/obsatcles
           // will move forward every 0.08 seconds
           if self.score>=20.0 && self.score<40.0{
               self.timerLevel = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()
           }
           // If the user's current score is between 40 and 60, the buildings/obsatcles
           // will move forward every 0.06 seconds
           if self.score>=40.0 && self.score<60.0{
               self.timerLevel = Timer.publish(every: 0.06, on: .main, in: .common).autoconnect()
           }
           // If the user's current score is more than 60, the buildings/obsatcles
           // will move forward every 0.04 seconds
           if self.score>=60.0{
               self.timerLevel = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
           }
       }
   }
   
   // Function to update the highscore of the user
   // If the current "score" of the user is more than the stored "highScore"
   // Then the highScore variable is updated and stored in the data as a userDefault
   func updateHighScore(){
       if self.score > self.highScore{
           self.highScore = self.score
           defaults.set(self.highScore, forKey: self.scoreKey)
       }
   }
   
   // Function to read the current highScore that is stored as a userDefault in the game's data
   func readHighScore(){
       self.highScore = Double(defaults.integer(forKey: self.scoreKey))
   }
   
   // Function to stop the timer
   // So the drone and building movement stops too
   func pause(){
       self.timerLevel.upstream.connect().cancel()
       self.timer.upstream.connect().cancel()
   }
   
   // Function to reset Timer to the initial state
   // The timer starts again and the movement of drone and building starts from initial positions
   func resume(){
       self.updateHighScore() // Function to update the high score by comparing it with the current score of the user
       self.isPaused = false
       self.score = 0 // Resetting score to 0
       self.timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
       self.timerLevel = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
       self.buildingPosition.x = 1000 // Moving building to the initial position
       self.dronePosition = CGPoint(x: 100, y:100) // Moving the drone to its initial position
   }
   
   // Function to move the drone downwards by 40 places
   // The movement is done using the withAnimation fucntion so the movement is smooth
   func gravity(){
       withAnimation{
           self.dronePosition.y += 40
       }
   }
   
   // Function to move the building forward and control the varying sizes of the building
   // The movement is done using the withAnimation function so that the movement is smooth
   func buildingMove(){
       
       // If the building is within the screen (i.e its x coordinate is more than 0)
       // Then the building is moved forward by 30 places (i.e towards the left of the screen)
       if self.buildingPosition.x>0{
           withAnimation{
               self.buildingPosition.x -= 30
           }
       }
       
       // If the buidling is not within the boundaries of the screen (i.e its x coordiantes are less than 0)
       // Then the buidling is moved to its original position
       else{
           // The x coordinate of the buidling is 1000
           self.buildingPosition.x = 1000
           
           // The building is has varying sizes by having random y coordinates each time
           self.buildingPosition.y = CGFloat.random(in: 0...400)
       }
   }
   
   func findingCollision(){
       
       /* If the diff b/w the x coordinates of drone and building are less than half
          the width of the two objects combined
          And if the diff b/w the y coordinates of the drone and the building are
          less than half the height of the two objects combined
          Then it shows that the objects have collided
          The absolute value of the diff in x and y coordinates are taken to cover
          all insances/all directions i.e from top, bottom, left and right
       */
       
       if abs(dronePosition.x - buildingPosition.x) < (25+10)
           && abs(dronePosition.y - buildingPosition.y) < (25+100){
           
           // If both of these conditions are met then the game is paused
           // And the isPaused variable is now true
           self.isPaused = true
           self.pause()
       }
   }
}

// Viewing the preview of the game, in landscape mode
struct ContentView_Previews: PreviewProvider{
   static var previews: some View{
       ContentView()
.previewInterfaceOrientation(.landscapeLeft)
   }
}

