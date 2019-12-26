import css from "../css/app.css";
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket, debug, View } from "phoenix_live_view";

let Hooks = {};

Hooks.ActiveSource = {
  mounted() {
    this.activeSourceType = null;
    this.activeSourceUrl = null;
    this.updateActiveSource();
  },
  updated() {
    this.updateActiveSource();
  },
  updateActiveSource() {
    const sourceType = this.el.dataset.type;
    const sourceUrl = this.el.dataset.url;

    if (sourceUrl) {
      this.el.scrollIntoView();
    }

    if (sourceType === "video" && sourceUrl) {
      if (this.activeSourceUrl !== sourceUrl) {
        this.pauseAudio();
        this.loadVideo(sourceUrl);
        this.activeSourceType = sourceType;
        this.activeSourceUrl = sourceUrl;
      }
    } else if (sourceType === "audio" && sourceUrl) {
      if (this.activeSourceUrl !== sourceUrl) {
        this.pauseVideo();
        this.playAudio(sourceUrl);
      }
    } else {
      this.pauseAudio();
      this.pauseVideo();
    }
  },
  loadVideo(url) {
    const hls = new Hls();
    const video = document.getElementById("video");

    if (Hls.isSupported()) {
      hls.attachMedia(video);
      hls.loadSource(url);
      hls.on(Hls.Events.MANIFEST_PARSED, function() {
        video.play();
      });
    }
    // hls.js is not supported on platforms that do not have Media Source Extensions (MSE) enabled.
    // When the browser has built-in HLS support (check using `canPlayType`), we can provide an HLS manifest (i.e. .m3u8 URL) directly to the video element throught the `src` property.
    // This is using the built-in support of the plain video element, without using hls.js.
    else if (video.canPlayType("application/vnd.apple.mpegurl")) {
      video.src = url;
      video.addEventListener("canplay", function() {
        video.play();
      });
    }
  },
  pauseVideo() {
    const video = document.getElementById("video");
    video.pause();
  },
  playAudio(url) {
    const audio = document.getElementById("audio");
    audio.addEventListener("canplay", function() {
      audio.play();
    });
  },
  pauseAudio() {
    const audio = document.getElementById("audio");
    audio.pause();
  }
};

let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks });

liveSocket.connect();
