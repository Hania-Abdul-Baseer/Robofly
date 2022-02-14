//
//  objects.swift
//  Robofly
//
//  Created by Hania Abdul Baseer on 14/2/2022.
//

import SwiftUI

// Declaring the Building component of the game which are the obstacles
// Is made up of a white rectangle of given height and width
struct Building: View{
    let height: CGFloat = 200 // The height of the obsatcle
    let width: CGFloat = 20   // The width of the obstacle
    
    var body: some View{
        Rectangle()
            .frame(width: width, height: height)
            .foregroundColor(Color.white)
    }
}

// Making the Drone component of the game using different colored blocks
struct Drone: View{
    let rows: Int = 10 // Number of rows of blocks used to construct the drone
    let columns: Int = 10 // Number of columns of blocks used to construct the drone
    let size: CGFloat = 5 // The width and height of each block of the drone
    
    // (rowsxcolumns) or (10x10) 2d array of type: Color that defines what each drone's block's color will be
    let droneBlocks: [[Color]] =  [[.gray, .gray, .gray, .clear, .clear, .clear, .clear, .gray, .gray, .gray],
                                  [.clear, .gray, .clear, .clear, .clear, .clear, .clear, .clear, .gray, .clear],
                                  [.clear, .gray, .clear, .clear, .clear, .clear, .clear, .clear, .gray, .clear],
                                  [.clear, .gray, .clear, .clear, .red, .red, .clear, .clear, .gray, .clear],
                                  [.cyan, .cyan, .cyan, .cyan, .cyan, .cyan, .cyan, .cyan, .cyan, .cyan],
                                  [.cyan, .cyan, .cyan, .cyan, .cyan, .cyan, .cyan, .cyan, .cyan, .cyan],
                                  [.clear, .clear, .cyan, .cyan, .cyan, .cyan, .cyan, .cyan, .clear, .clear],
                                  [.clear, .clear, .gray, .clear, .clear, .clear, .clear, .gray, .clear, .clear],
                                  [.clear, .clear, .gray, .clear, .clear, .clear, .clear, .gray, .clear, .clear],
                                  [.clear, .gray, .gray, .clear, .clear, .clear, .clear, .gray, .gray, .clear]]
    
    var body: some View{
        // Building the drone using square blocks
        // For within a for loop to iterate over every element of the 2d array droneBlocks
        VStack (spacing: 0){
            ForEach((0...self.rows-1), id: \.self){row in
                HStack (spacing: 0){
                    ForEach((0...self.columns-1), id: \.self){col in
                        VStack (spacing: 0){
                            // Making square blocks of given color using the droneBlocks 2d array
                            Rectangle().frame(width: size, height: size).foregroundColor(self.droneBlocks[row][col])
                        }
                    }
                }
            }
        }
    }
}

