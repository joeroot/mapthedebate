/* 
  PROCESSINGJS.COM - BASIC EXAMPLE
  Delayed Mouse Tracking  
  MIT License - Hyper-Metrix.com/F1LT3R
  Native Processing compatible 
*/  

// Global variables
float radius = 20.0;
int X, Y;
int nX, nY;
int delay = 16;
var results = [];

// Setup the Processing Canvas
void setup(){
	$.get('http://localhost:4567/api/results.json', function(json){
	  // results = data["results"];
		$("#dump").prepend(json);
		results = $.parseJSON(json)["results"];
		// alert(results);
		size( 960, 600 );
	  strokeWeight( 2 );
	  frameRate( 15 );
	  X = width / 2;
	  Y = width / 2;
	  nX = X;
	  nY = Y;
	draw();
	}); 
}

// Main draw loop
void draw(){
  background( #222222 );
	for (i = 0; i < results.length; i++) {
		tweet = results[i];
	  // radius = radius + sin( frameCount / 4 );
	  // Track circle to new destination
	  X =i*20+30;
	  Y =i*20+30;

	  // Fill canvas grey

	  // Set fill-color to blue
		if (tweet.polarity == "pos") {
		  fill( 0, 121, 184 );
		} else {
			fill( 200, 201, 184 );
		}

	  // Set stroke-color white
	  stroke(255); 

	  // Draw circle
	  ellipse( X, Y, radius, radius );  
	}           
}


// Set circle's next destination
void mouseMoved(){
  nX = mouseX;
  nY = mouseY;  
}

void mousePressed(){
  X = mouseX;
  Y = mouseY;  
}