package vocally;

import haxe.ds.Either;
import haxe.extern.EitherType;
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

	public function listenOnce(): Recognizer {
		return newRecogniser().start(false);
	}

	public function listen(): Recognizer {
		return newRecogniser().start(true);
	}

	public function listenFor(commandOrCommands: Either<ListenForCommand, Array<ListenForCommand>>): Recognizer {
		var commands: Array<ListenForCommand> =
			(Std.is(commandOrCommands, Array))
			? cast commandOrCommands
			: [cast commandOrCommands];
		var draftCommands = commands.filter(c -> c.respondOnDraft);
		var sureCommands = commands.filter(c -> !c.respondOnDraft);
		// Keep track of which draft commands have already run, so they aren't triggered again for each updated draft.
		var draftCommandsTriggered = [];
		function match(commandAlts: Array<String>, transcriptAlts: Array<String>) {
			// TODO: allow repeating a command within a draft by saying it twice (but not by the draft triggering twice)
			for (cmd in commandAlts) {
				var cmdRegex = new EReg(cmd, 'i');
				for (transcript in transcriptAlts) {
					if (cmdRegex.match(transcript)) {
						var wildcards = [];
						var i = 0;
						while (true) {
							try {
								wildcards.push(cmdRegex.matched(i++));
							} catch (e: Dynamic) {
								break;
							}
						}
						return Some({
							transcript: transcript,
							command: cmd,
							wildcards: wildcards
						});
					}
				}
			}
			return None;
		}
		function checkCommands(result: SpeechRecognitionResult, commands: Array<ListenForCommand>, commandsToIgnore: Array<ListenForCommand>) {
			for (cmd in commands) {
				if (commandsToIgnore.indexOf(cmd) > -1) {
					continue;
				}
				var cmdAlts = [cmd.command].concat(cmd.alternatives != null ? cmd.alternatives : []);
				var transcriptAlts = [for (alt in result) alt.transcript];
				switch match(cmdAlts, transcriptAlts) {
					case Some(match):
						draftCommandsTriggered.push(cmd);
						cmd.handler.invoke(match);
					case None:
				}
			}
		}
		return newRecogniser()
			.onDraftAlternatives(draft -> checkCommands(draft, draftCommands, draftCommandsTriggered))
			.onResultAlternatives(result -> {
				draftCommandsTriggered = [];
				checkCommands(result, sureCommands, []);
			})
			.start(true);
	}

	/** Abort all current SpeechRecognition listeners. **/
	public function stopListening(): VSpeechRecognition {
		for (r in allRecognizers) {
			r.abort();
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
	var results: Option<SpeechRecognitionResultList>;
	var resultSignal: SignalTrigger<SpeechRecognitionAlternative>;
	var resultAlternativesSignal: SignalTrigger<SpeechRecognitionResult>;
	var draftSignal: SignalTrigger<SpeechRecognitionAlternative>;
	var draftAlternativesSignal: SignalTrigger<SpeechRecognitionResult>;
	var errorSignal: SignalTrigger<SpeechRecognitionError>;
	var promise: Option<{
		promise: Promise<FinalSpeechRecognitionResult>,
		resolve: FinalSpeechRecognitionResult -> Void,
		reject: SpeechRecognitionError -> Void
	}>;

	public function new(cls: Class<SpeechRecognition>) {
		recognizer = Type.createInstance(cls, []);
		resultSignal = new SignalTrigger();
		resultAlternativesSignal = new SignalTrigger();
		draftSignal = new SignalTrigger();
		draftAlternativesSignal = new SignalTrigger();
		errorSignal = new SignalTrigger();
		promise = None;
		results = None;

		recognizer.continuous = true;
		recognizer.lang = "en-US";
		recognizer.interimResults = true;
		recognizer.maxAlternatives = 3;

		recognizer.addEventListener("result", (e: SpeechRecognitionEvent) -> {
			var results = e.results;
			this.results = Some(results);
			var lastResult = results[results.length - 1];
			if (lastResult.length > 0) {
				var alternative = lastResult[0];
				var signal = lastResult.isFinal ? resultSignal : draftSignal;
				var alternativesSignal =
					lastResult.isFinal
					? resultAlternativesSignal
					: draftAlternativesSignal;
				signal.trigger(alternative);
				alternativesSignal.trigger(lastResult);
			}
		});
		recognizer.addEventListener("speechend", () -> stop());
		recognizer.addEventListener("nomatch", (e: SpeechRecognitionEvent) -> {
			// Try again until we get some speech.
			start();
		});
		recognizer.addEventListener("end", (e: Event) -> {
			if (recognizer.continuous) {
				start();
				return;
			}

			switch [promise, results] {
				case [Some(p), Some(resultList)]:
					var finalResult: FinalSpeechRecognitionResult = {
						allResults: resultList,
						transcript: '',
						confidence: 0,
					};
					for (result in resultList) {
						finalResult.transcript += " " + result[0].transcript;
						finalResult.confidence += result[0].confidence / resultList.length;
					}
					p.resolve(finalResult);
				case _:
			}
		});
		recognizer.addEventListener("error", (e: {error: SpeechRecognitionError}) -> {
			var err = e.error;
			if (err.message == "no-speech") {
				stop();
				return;
			}
			errorSignal.trigger(err);
			switch promise {
				case Some(p): p.reject(err);
				case _:
			}
		});
	}

	/** Start listening for a new result. **/
	public function start(?keepRestarting: Bool = true): Recognizer {
		recognizer.continuous = keepRestarting;
		recognizer.start();
		return this;
	}

	/** Stop listening, and try to get a final result. **/
	public function stop(): Recognizer {
		recognizer.continuous = false;
		recognizer.stop();
		return this;
	}

	/** Stop listening, and don't attempt to get a final result. **/
	public function abort(): Recognizer {
		recognizer.abort();
		return this;
	}

	public function onResult(cb: Callback<SpeechRecognitionAlternative>): Recognizer {
		resultSignal.handle(cb);
		return this;
	}

	public function onResultAlternatives(cb: Callback<SpeechRecognitionResult>): Recognizer {
		resultAlternativesSignal.handle(cb);
		return this;
	}

	public function onDraft(cb: Callback<SpeechRecognitionAlternative>): Recognizer {
		draftSignal.handle(cb);
		return this;
	}

	public function onDraftAlternatives(cb: Callback<SpeechRecognitionResult>): Recognizer {
		draftAlternativesSignal.handle(cb);
		return this;
	}

	public function onError(cb: Callback<SpeechRecognitionError>): Recognizer {
		errorSignal.handle(cb);
		return this;
	}

	public function finalResult(): Promise<FinalSpeechRecognitionResult> {
		switch promise {
			case Some(p):
				return p.promise;
			case None:
				var resolve = null;
				var reject = null;
				var p = new Promise(function (resolveFn, rejectFn) {
					resolve = resolveFn;
					reject = rejectFn;
				});
				promise = Some({
					promise: p,
					resolve: resolve,
					reject: reject
				});
				return p;
		}
	}
}

/**
An object for receiving multiple recognition results.
It is similar to SpeechRecognitionAlternative, with a confidence and transcript for the combined result.
It gives access to each of the result lists that were used to generate the combined result.
**/
typedef FinalSpeechRecognitionResult = {
	allResults: SpeechRecognitionResultList,
	confidence: Float,
	transcript: String,
}

typedef ListenForCommand = {
	/** The command we are listening for **/
	var command: String;
	/** A function to execute when the command is recognised. **/
	var handler: Callback<{
		/** The transcript of the result that matched. **/
		var transcript: String;
		/** The command text (or alternative command text) that matched. **/
		var command: String;
		/** Any wildcards found. **/
		var wildcards: Array<String>;
	}>;
	/** Whether to wait for a final result or execute as soon as it occurs in a draft. **/
	@:optional var respondOnDraft: Bool;
	/** Alternative versions of the **/
	@:optional var alternatives: Array<String>;
}
