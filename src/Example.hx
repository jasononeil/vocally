import readout.ReadOut;
import js.Browser.*;

class Example {
	static function main() {
		window.addEventListener("load", () -> {
			var readout = new ReadOut();
			setupEvents(readout);

			// readout
			// 	.say('Hello')
			// 	.pauseFor(1)
			// 	.say('my name is ${readout.voice.name}')
			// 	.say('But you can call me computer');
			readout.read(document.querySelector('article'));

			var current = document.querySelector("#current");
			trace(current);
			readout.onSpeak(u -> current.innerText = u.text);
		});
	}

	static function setupEvents(readout: ReadOut) {
		var btnPlayPause = document.querySelector("#btn_playpause");
		btnPlayPause.addEventListener("click", () -> readout.togglePlaying());
	}
}