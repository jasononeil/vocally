import readout.ReadOut;
import js.Browser.*;

class Example {
	static function main() {
		window.addEventListener("load", () -> {
			var ReadOut = new ReadOut();
			setupEvents(ReadOut);

			// ReadOut
			// 	.say('Hello')
			// 	.pauseFor(1)
			// 	.say('my name is ${ReadOut.voice.name}')
			// 	.say('But you can call me computer');
			ReadOut.read(document.querySelector('article'));

			var current = document.querySelector("#current");
			trace(current);
			ReadOut.onSpeak(u -> current.innerText = u.text);
		});
	}

	static function setupEvents(ReadOut: ReadOut) {
		var btnPlayPause = document.querySelector("#btn_playpause");
		btnPlayPause.addEventListener("click", () -> ReadOut.togglePlaying());
	}
}