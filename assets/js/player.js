import SoundManager2 from "soundmanager2/script/soundmanager2"
import Playem from "playemjs/playem"
import YoutubePlayer from "playemjs/playem-youtube"

export class Player {
  constructor(tracksUrls) {
    var self         = this;
    this._playem     = new Playem();
    this._tracksUrls = tracksUrls;
    this._state      = "stop";

    var config = {
      playerContainer: document.getElementById("playem_video")
    };

    this._playem.addPlayer(YoutubePlayer, config);

    this._tracksUrls.forEach(function(trackUrl) {
      self._playem.addTrackByUrl(trackUrl);
    });
  }

  get playem() {
    return this._playem;
  }

  get state() {
    return this._state;
  }

  get currentTrackIndex() {
    return this._currentTrackIndex;
  }

  set currentTrackIndex(index) {
    this._currentTrackIndex = index;
  }

  get tracksUrls() {
    return this._tracksUrls;
  }

  play(trackIndex) {
    this._playem.play(trackIndex);
    this._currentTrackIndex = parseInt(trackIndex);
    this._state = "playing"
  }

  playNext() {
    this.play(this._currentTrackIndex + 1);
  }

  playPrevious() {
    this.play(this._currentTrackIndex - 1);
  }

  pause() {
    this._playem.pause();
    this._state = "paused"
  }

  resume() {
    this._playem.resume();
    this._state = "playing"
  }
}
