import {Player} from "./player"

// TODO: for the love of god, use REACT or something
function hightlightOnlyCurrentSongCard(listPlayIcon) {
  listPlayIcons.forEach(function(listPlayIcon) {
    listPlayIcon.closest('.song-card').style["background-color"] = "white";
  });

  var songCard = listPlayIcon.closest('.song-card')

  songCard.style["background-color"] = "gray";
  songCard.style["color"] = "white";

  // NOTE: :| :(
  Array.from(songCard.getElementsByTagName('a')).forEach(function(link) {
    link.style["color"] = "black"

    link.onmouseout = function(){
      this.style["color"] = "black"
    }

    link.onmouseover = function(){
      this.style["color"] = "white"
    }
  });
};

function setPlaying(listPlayIcon) {
  hightlightOnlyCurrentSongCard(listPlayIcon);

  var mainPlayButton = document.getElementById("play-current");
  mainPlayButton.classList.remove("fa-play")
  mainPlayButton.classList.add("fa-pause");

  window.currentListPlayIcon = listPlayIcon;
  if (player.state == "paused" && player.currentTrackIndex == listPlayIcon.dataset.songIndex) {
    // TODO: listPlayIcon is useless here, refactor
    player.resume();
  } else {
    player.play(listPlayIcon.dataset.songIndex);
  }
};

function setPaused(listPlayIcon) {
  var mainPlayButton = document.getElementById("play-current");
  mainPlayButton.classList.remove("fa-pause");
  mainPlayButton.classList.add("fa-play")

  // force-remove loading icon
  document.getElementById('song-loading').classList.add('is-invisible');

  player.pause();
};

function setSongTitle(title) {
  document.getElementById('song-title').innerHTML = title;
}

function toggleMainPlayButton(mainPlayButton) {
  if (mainPlayButton.classList.contains("fa-play")) {
    mainPlayButton.classList.remove("fa-play");
    mainPlayButton.classList.add("fa-pause");

    // TODO: resume song instead of playing it from the
    // start
    setPlaying(window.currentListPlayIcon);
  } else {
    mainPlayButton.classList.remove("fa-pause");
    mainPlayButton.classList.add("fa-play");

    setPaused(window.currentListPlayIcon);
  }
}

document.addEventListener("DOMContentLoaded", function() {
  window.listPlayIcons = Array.from(document.querySelectorAll(".song-card i"));
  //
  // setting up player
  //
  var tracksUrls = listPlayIcons.map(function(playIcon) {
    return playIcon.dataset.songUrl;
  });

  window.player = new Player(tracksUrls);

  player.playem.on("onTrackChange", function(event){
    hightlightOnlyCurrentSongCard(listPlayIcons[event.index]);

    mainPlayButton.classList.remove("fa-play");
    mainPlayButton.classList.add("fa-pause");

    player.currentTrackIndex = event.index;

    document.getElementById('song-loading').classList.remove('is-invisible');
    // cant retrieve currentListPlayIcon
    setSongTitle(listPlayIcons[event.index].dataset.songTitle);
  });

  player.playem.on("onPlay", function(event){
    document.getElementById('song-loading').classList.add('is-invisible');
  });

  document.getElementById('play-next').addEventListener('click', function(event) {
    if (player.currentTrackIndex < player.tracksUrls.length - 1) {
      player.playNext();
      window.currentListPlayIcon = listPlayIcons[player.currentTrackIndex]
    }
  });

  document.getElementById('play-previous').addEventListener('click', function(event) {
    if (player.currentTrackIndex > 0) {
      player.playPrevious();
      window.currentListPlayIcon = listPlayIcons[player.currentTrackIndex]
    }
  });
  //
  // main play button event
  //
  var mainPlayButton = document.getElementById("play-current");

  mainPlayButton.addEventListener('click', function(event) {
    toggleMainPlayButton(this);
  });
  //
  // song list events
  //
  listPlayIcons.forEach(function(listPlayIcon) {
    listPlayIcon.addEventListener('click', function(event) {
      document.getElementById('player').classList.add('appear');
      setPlaying(this)
    });
  });
});
