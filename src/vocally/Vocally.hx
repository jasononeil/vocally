package vocally;

import js.html.*;
import js.Browser.*;
import vocally.Synthesis;
import vocally.Recognition;
using tink.CoreApi;

#if compile_library
@:keep
#end
class Vocally {
	#if compile_library
	@:expose("Vocally")
	#end
	public static var instance = new Vocally();

	public var synthesis(default, null): Synthesis;
	public var recognition(default, null): Recognition;

	public function new() {
		this.synthesis = new Synthesis();
		this.recognition = new Recognition();
	}

	/**
	Say a single string out loud.
	**/
	public function say(text: String, ?options: VoiceOptions): Vocally {
		synthesis.say(text, options);
		return this;
	}

	/**
	Pause for a certain amount of time.
	Please note due to implementation details the pause will likely be slightly too long.
	It's a pretty crummy implementation.
	**/
	public function pauseFor(timeInSeconds: Float): Vocally {
		synthesis.pauseFor(timeInSeconds);
		return this;
	}

	/** Read the text content of a DOM node. **/
	public function read(element: Element, ?options: VoiceOptions): Vocally {
		synthesis.read(element, options);
		return this;
	}

	/** Stop speaking and cancel all the utterances in the queue. **/
	public function cancel(): Vocally {
		synthesis.cancel();
		return this;
	}

	/** Pause the current utterance, allowing you to restart from the same point later. **/
	public function pause(): Vocally {
		synthesis.pause();
		return this;
	}

	/** Resume playing from the paused position. **/
	public function resume(): Vocally {
		synthesis.resume();
		return this;
	}

	/** If currently playing, then pause. If currently paused, then resume. **/
	public function togglePlaying(): Vocally {
		synthesis.togglePlaying();
		return this;
	}

	/**

	**/
	public function onSpeak(cb: Callback<SpeechSynthesisUtterance>): Vocally {
		synthesis.onSpeak(cb);
		return this;
	}
}
