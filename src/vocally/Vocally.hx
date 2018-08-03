package vocally;

import js.html.*;
import js.Browser.*;
import vocally.VSpeechSynthesis;
import vocally.VSpeechRecognition;
using tink.CoreApi;

#if compile_library
@:keep
@:expose("vocally")
#end
/**
A class for more convenient interaction with the Web Speech API - both Speech Synthesis and Speech Recognition.

Please note most of the magic is in the Synthesis and Recognition classes.
This module aims to provide a convenient API to use from JavaScript without worrying about creating any instances of objects.
**/
class Vocally {
	public static var synthesis(default, null) = new VSpeechSynthesis();
	public static var recognition(default, null) = new VSpeechRecognition();

	// SYNTHESIS

	/**
	Say a single string out loud.
	**/
	public static function say(text: String, ?options: VoiceOptions) {
		synthesis.say(text, options);
		return Vocally;
	}

	/**
	Pause for a certain amount of time.
	Please note due to implementation details the pause will likely be slightly too long.
	It's a pretty crummy implementation.
	**/
	public static function pauseFor(timeInSeconds: Float) {
		synthesis.pauseFor(timeInSeconds);
		return Vocally;
	}

	/** Read the text content of a DOM node. **/
	public static function read(element: Element, ?options: VoiceOptions) {
		synthesis.read(element, options);
		return Vocally;
	}

	/** Stop speaking and cancel all the utterances in the queue. **/
	public static function cancel() {
		synthesis.cancel();
		return Vocally;
	}

	/** Pause the current utterance, allowing you to restart from the same point later. **/
	public static function pause() {
		synthesis.pause();
		return Vocally;
	}

	/** Resume playing from the paused position. **/
	public static function resume() {
		synthesis.resume();
		return Vocally;
	}

	/** If currently playing, then pause. If currently paused, then resume. **/
	public static function togglePlaying() {
		synthesis.togglePlaying();
		return Vocally;
	}

	/**
	Be informed of each SpeechSynthesisUtterance that is spoken by the browser.
	This is useful for providing a visual alternative for users who prefer reading to listening.
	**/
	public static function onSpeak(cb: Callback<SpeechSynthesisUtterance>) {
		synthesis.onSpeak(cb);
		return Vocally;
	}

	// RECOGNITION

	public static function transcribe() {
		return recognition.transcribe();
	}

	public static function transcribeLongForm() {
		return recognition.transcribeLongForm();
	}

	public static function listenFor(commands: Either<ListenForCommand, Array<ListenForCommand>>) {
		return recognition.listenFor(commands);
	}

	public static function stopListening() {
		return Vocally;
	}

	public static function usePolyfill(polyfill: Class<SpeechRecognition>) {
		return Vocally;
	}
}
