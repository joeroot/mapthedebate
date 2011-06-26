var paper;
var tweets;

function setup(){
	paper = new Raphael(document.getElementById('map'), 920, 600); 
	$.get('http://localhost:4567/api/results.json?rpp=200', function(json){
	  // results = data["results"];
		$("#dump").prepend(json);
		tweets = $.parseJSON(json)["results"];
		draw();
	}); 
}

function draw(){
	for (i = 0; i < tweets.length; i++) {
		drawTweet(i);
	}
}

function drawTweet(i){
	var tweet = tweets[i];
	var circle = paper.circle(i*20+20, i*10+20, 10);
	// Sets the fill attribute of the circle to red (#f00)
	
	
	circle.attr({
		"fill": "#f00",
		"stroke": "#fff",
		"stroke-width": 2
	});
}

$(document).ready(function(){
	setup();
});