package vocally;

import js.html.*;
import js.Browser.*;
using tink.CoreApi;

typedef VoiceOptions = {
	?lang: String,
	?pitch: Float,
	?rate: Float,
	?voice: SpeechSynthesisVoice,
	?volume: Float,
};

#if compile_library
@:keep
#end
class Synthesis {
	public var voice: SpeechSynthesisVoice;
	var utterSignal: SignalTrigger<SpeechSynthesisUtterance>;
	var speechSynthesis: SpeechSynthesis;
	var utterances: Array<SpeechSynthesisUtterance>;
	var targetLength = 115;

	public function new() {
		this.speechSynthesis = window.speechSynthesis;
		this.voice = getDefaultVoice();
		this.utterances = [];
		this.utterSignal = new SignalTrigger();
	}

	/**
	Say a piece of text
	**/
	public function say(text: String, ?options: VoiceOptions): Synthesis {
		for (fragment in splitStringIntoChunks(text, targetLength)) {
			var utterance = new SpeechSynthesisUtterance(fragment);
			if (options != null) {
				if (options.lang != null) utterance.lang = options.lang;
				if (options.pitch != null) utterance.pitch = options.pitch;
				if (options.rate != null) utterance.rate = options.rate;
				if (options.voice != null) utterance.voice = options.voice;
				if (options.volume != null) utterance.volume = options.volume;
			} else {
				utterance.voice = this.voice;
			}
			utterance.addEventListener("start", () -> {
				utterSignal.trigger(utterance);
			});

			function pauseAndRestart() {
				speechSynthesis.pause();
				speechSynthesis.resume();
			}

			utterances.push(utterance);
			speechSynthesis.speak(utterance);
		}
		return this;
	}

	/**
	Pause for a certain amount of time.
	Please note due to implementation details the pause will likely be slightly too long.
	It's a pretty crummy implementation.
	**/
	public function pauseFor(timeInSeconds: Float): Synthesis {
		// We need something that is read aloud, and "..." is read aloud as "dot".
		// When it is read, we manually pause and restart after a timeout, and make sure the utterance has no volume.
		// A better solution may be to use an SSML mark to add a gap.
		var pause = new SpeechSynthesisUtterance('...');
		pause.volume = 0;
		pause.voice = this.voice;
		pause.addEventListener("start", (e: SpeechSynthesisEvent) -> {
			speechSynthesis.pause();
			window.setTimeout(
				() -> speechSynthesis.resume(),
				Math.round(timeInSeconds * 1000)
			);
		});
		utterances.push(pause);
		speechSynthesis.speak(pause);
		return this;
	}

	/**
	Read a DOM node
	**/
	public function read(element: Element, ?options: VoiceOptions): Synthesis {
		if (element == null) return this;
		var currentText = "";
		for (child in element.childNodes) {
			switch child.nodeType {
				case NodeType.Element:
					var childElement: Element = cast child;
					var displayStyle = window.getComputedStyle(childElement).display;
					if (displayStyle == "inline" || displayStyle == "inline-block") {
						// It would be great to use SSML marks for <em> and <strong>, but browser support is awful.
						currentText += child.textContent + " ";
					} else {
						// For block level elements, read them as a separate utterance.
						say(currentText, options);
						read(childElement);
						currentText = "";
					}
				case NodeType.Text:
					currentText += child.textContent + " ";
				default:
			}
		}
		say(currentText, options);
		return this;
	}

	/**

	**/
	public function onSpeak(cb: Callback<SpeechSynthesisUtterance>): Synthesis {
		utterSignal.handle(cb);
		return this;
	}

	public function cancel(): Synthesis {
		speechSynthesis.cancel();
		return this;
	}

	public function pause(): Synthesis {
		speechSynthesis.pause();
		return this;
	}

	public function resume(): Synthesis {
		speechSynthesis.resume();
		return this;
	}

	public function togglePlaying(): Synthesis {
		if (speechSynthesis.paused) {
			speechSynthesis.resume();
		} else {
			speechSynthesis.pause();
		}
		return this;
	}

	public function getVoices(): Array<SpeechSynthesisVoice> {
		return speechSynthesis.getVoices();
	}

	public function getDefaultVoice(): SpeechSynthesisVoice {
		var allVoices = getVoices();
		for (voice in allVoices) {
			if (voice.default_) {
				return voice;
			}
		}
		return allVoices[0];
	}

	/*
	This is a workaround for a Chrome bug that cuts off SpeechUtterances that last longer than 15 seconds.
	We try work around the issue by splitting long text into small chunks at sentence boundaries, punctuation marks, or word boundaries.
	See https://stackoverflow.com/questions/21947730/chrome-speech-synthesis-with-longer-texts/47426888#47426888
	*/
	static function splitStringIntoChunks(text: String, targetLength: Int): Array<String> {
		var fragments = [];
		while (text.length > targetLength) {
			var remainingText = text;
			for (char in ['."', '.', '!"', '!', '?"', '?', ';', ':', ',', '\n\n', '\n', '\t', ' ']) {
				var index = text.lastIndexOf(char, targetLength);
				if (index > -1) {
					fragments.push(text.substr(0, index + char.length));
					remainingText = text.substr(index + char.length);
					break;
				}
			}
			if (remainingText == text) {
				// If there was nothing to split on by here, we have a run of words longer than our content.
				// Nothing to do but hope it finishes before Chrome's 15 second bug kicks in and cuts us off.
				break;
			}
			text = remainingText;
		}
		fragments.push(text);
		return fragments;
	}
}

enum abstract NodeType(Int) {
	var Element = 1;
	var Text = 3;
}