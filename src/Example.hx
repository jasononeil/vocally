import vocally.Vocally;
import js.Browser.*;

class Example {
	static function main() {
		window.addEventListener("load", () -> {
			setupEvents();

			var current = document.querySelector("#current");

			var fred = Vocally.synthesis.getVoices().filter(v -> v.name == 'Fred')[0];

			Vocally.say('Hello')
				.pauseFor(1)
				.say('my name is ${Vocally.synthesis.getDefaultVoice().name}')
				.say('But you can call me')
				.say('computer', {voice: fred})
				.read(document.querySelector('article'))
				.onSpeak(u -> current.innerText = u.text);

		});
	}

	static function setupEvents() {
		var btnPlayPause = document.querySelector("#btn_playpause");
		btnPlayPause.addEventListener("click", () -> Vocally.togglePlaying());
	}
}