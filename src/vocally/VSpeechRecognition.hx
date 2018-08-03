package vocally;

import haxe.ds.Either;
import js.Browser.window;
import js.html.*;
import haxe.ds.Option;
import js.Promise;
using tink.core.Signal;
using tink.core.Callback;

#if compile_library
@:keep
#end
class VSpeechRecognition {
	var speechRecognition: Option<Class<SpeechRecognition>>;
	var allRecognizers: Array<Recognizer>;

	public function new() {
		this.allRecognizers = [];
		this.speechRecognition = None;

		if (Reflect.hasField(window, 'SpeechRecognition')) {
			this.speechRecognition = Some(Reflect.field(window, 'SpeechRecognition'));
		} else if (Reflect.hasField(window, 'webkitSpeechRecognition')) {
			this.speechRecognition = Some(Reflect.field(window, 'webkitSpeechRecognition'));
		}
	}

	public function transcribe(): Recognizer {
		return newRecogniser().start();
	}

	public function transcribeLongForm(): Recognizer {
		return newRecogniser().start();
	}

	public function listenFor(commands: Either<ListenForCommand, Array<ListenForCommand>>): VSpeechRecognition {
		return this;
	}

	public function stopListening(): VSpeechRecognition {
		for (r in allRecognizers) {
			r.stop();
		}
		return this;
	}

	public function usePolyfill(polyfill: Class<SpeechRecognition>): VSpeechRecognition {
		this.speechRecognition = Some(polyfill);
		return this;
	}

	function newRecogniser(): Recognizer {
		switch speechRecognition {
			case Some(cls):
				var recognizer = new Recognizer(cls);
				allRecognizers.push(recognizer);
				return recognizer;
			case None:
				throw 'SpeechRecognition is not supported in this browser and a polyfill was not found';
		}
	}
}

#if compile_library
@:keep
#end
class Recognizer {
	public var recognizer: SpeechRecognition;
	var promise: Promise<SpeechRecognitionResultList>;
	var draftSignal: SignalTrigger<SpeechRecognitionAlternative>;
	var errorSignal: SignalTrigger<SpeechRecognitionError>;

	public function new(cls: Class<SpeechRecognition>) {
		recognizer = Type.createInstance(cls, []);
		draftSignal = new SignalTrigger();
		errorSignal = new SignalTrigger();

		recognizer.continuous = true;
		recognizer.lang = "en-US";
		recognizer.interimResults = true;
		recognizer.maxAlternatives = 3;

		promise = new Promise((resolve: SpeechRecognitionResultList -> Void, reject: SpeechRecognitionError -> Void) -> {
			recognizer.addEventListener("result", (e: SpeechRecognitionEvent) -> {
				var results = e.results;
				for (result in results) {
					if (result.isFinal) {
						resolve(results);
						break;
					} else {
						if (result.length > 0) {
							var alternative = result[0];
							draftSignal.trigger(alternative);
							break;
						}
					}
				}
			});
			recognizer.addEventListener("nomatch", (e: SpeechRecognitionEvent) -> {
				// Try again until we get some speech.
				start();
			});
			recognizer.addEventListener("end", (e: Event) -> {});
			recognizer.addEventListener("error", (e: {error: SpeechRecognitionError}) -> {
				var err = e.error;
				if (err.message == "no-speech") {
					// Try again until we get some speech.
					start();
					return;
				}
				errorSignal.trigger(err);
				reject(err);
			});
		});
	}

	public function start(): Recognizer {
		recognizer.start();
		return this;
	}

	public function stop(): Recognizer {
		recognizer.stop();
		return this;
	}

	public function onDraft(cb: Callback<SpeechRecognitionAlternative>): Recognizer {
		draftSignal.handle(cb);
		return this;
	}

	public function onError(cb: Callback<SpeechRecognitionError>): Recognizer {
		errorSignal.handle(cb);
		return this;
	}

	public function finalResult(): Promise<SpeechRecognitionResultList> {
		return promise;
	}
}

typedef ListenForCommand = {
	text: String,
	handler: Callback<Array<String>>,
	waitForFinal: Bool,
	alternatives: Array<String>,
}
