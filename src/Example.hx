import vocally.Vocally;
import js.Browser.*;

class Example {
	static function main() {
		window.addEventListener("load", () -> {
			var vocally = new Vocally();
			setupEvents(vocally);

			vocally
				.say('Hello')
				.pauseFor(1)
				.say('my name is ${vocally.synthesis.voice.name}')
				.say('But you can call me computer');
			vocally.read(document.querySelector('article'));

			var current = document.querySelector("#current");
			vocally.onSpeak(u -> current.innerText = u.text);
		});
	}

	static function setupEvents(vocally: Vocally) {
		var btnPlayPause = document.querySelector("#btn_playpause");
		btnPlayPause.addEventListener("click", () -> vocally.togglePlaying());
	}
}