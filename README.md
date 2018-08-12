# Vocally

 A friendly wrapper around the Web Speech API (VoiceRecognition and VoiceSynthesis) for JavaScript.

 The Web Speech API includes two main parts:

 - [SpeechSynthesis][] - teaching your page to talk. [Works in most modern browsers][can-i-use-synthesis].
 - [SpeechRecognition][] - teaching your page to listen. [Currently Chrome only][can-i-use-recognition], but [can be polyfilled with commercial APIs][bing-polyfill].

 Vocally is an easy to use JavaScript API for interacting with both.

[SpeechSynthesis]: https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesis
[can-i-use-synthesis]: https://caniuse.com/#search=speechsynthesis
[SpeechRecognition]: https://developer.mozilla.org/en-US/docs/Web/API/SpeechRecognition
[can-i-use-recognition]: https://caniuse.com/#search=speechrecognition
[bing-polyfill]: https://github.com/compulim/web-speech-cognitive-services

## Installation

TODO

## Usage

TODO

- `import vocally from 'vocally';`

### Making it speak

The basic API:

- `vocally.say('Hello!')` - read a single string out loud
- `vocally.read(someElement)` - read out all of the text in an element
- `vocally.pauseFor(3)` - add a gap before saying the next thing
- `vocally.pause()` - pause where you are at
- `vocally.resume()` - resume from where you paused
- `vocally.togglePlaying()` - pause or resume
- `vocally.onSpeak(utterance => console.log('we said', utterance))` - receive a callback every time a new "utterance" is spoken - useful for providing a visual alternative for those who prefer reading to listening.

You can chain these together:

```js
vocally
	.say("Alright, let's read this article!")
	.pause(2)
	.read(document.querySelector('article'))
	.onSpeak(utterance => textAlternative.innerText = utterance.text);
```

And helpers:

- `vocally.synthesis.getVoices(): Array<SpeechSynthesisVoice>`
- `vocally.synthesis.getDefaultVoice(): SpeechSynthesisVoice`

### Making it listen

- `vocally.listenOnce(): Recognizer` - listen for the first recognition result - suitable for a single short sentence, input or command.
- `vocally.listen(): Recognizer` - keep transcribing until you tell it to stop.
- `vocally.listenFor(command)` or `vocally.listenFor([command1, command2, ...])`

  Simple example:

  ```js
  vocally.listenFor([
	  {
		  command: 'up',
		  respondOnDraft: false, // execute even if it's a draft response
		  handler: () => window.scrollTo(0, window.pageYOffset - 100)
	  },
	  {
		  command: 'down',
		  respondOnDraft: false, // execute even if it's a draft response
		  handler: () => window.scrollTo(0, window.pageYOffset + 100)
	  }
  ])
  ```

  Your commands and alternatives are treated as regular expressions, so you can do wildcard matches:

  ```js
  vocally.listenFor({
	command: 'my name is (\w+)',
	alternatives: ['I am (\w+)', 'you can call me (\w+)'],
	handler: (matched) => {
		// matched: { command: {...}, alternative: 'I am (\w+)', matches: ['i am jason', 'jason'] }
		let name = matched.wildcards[1];
		vocally.say(`Hello ${name}`);
	}
  })
  ```

- `vocally.stopListening()`

## Examples

## Project details

### Getting support

Please open an issue on Github if you need help using Vocally.

### Contributing

I would love help in the following areas:

- Creating documentation and examples
- Pull requests - help us build the project!
- Setting up continuous integration and cross-browser tests

If you're a junior developer and would like to contribute, but are not sure where to start - ask me, via email (jason@jasono.co) or by opening a Github issue to discuss.

### The name

I chose the name because it's a relevant word that wasn't already taken (*The first page of Google results for `vocally js` produced nothing to do with software at the time I chose it*).

I also liked how I imagined the API methods would sound: `vocally.say()`, `vocally.read()`, `vocally.listen()`.

Finally, I thought it was a node to the Accessibility community, which often uses the numeronym "a11y" (or "ally") as an abbreviation - because I had the idea for this project starting at the Perth Web Accessibility Camp in 2018, and I believe the biggest opportunity for this technology is to make the web inclusive to more people in more ways.

### Other projects

Seemingly abandoned projects:

- https://www.npmjs.com/package/speechless
- https://github.com/sdkcarlos/artyom.js/
- https://www.npmjs.com/package/speechjs

### License

All code is released under the MIT license. See [LICENSE.md][]

[LICENSE.md]: ./LICENSE.md

### Code of conduct

I've set up a [Code of Conduct][], in the hope that if this project develops into a community, it is a great community to be part of. The code of conduct is based on the [Contributor Covenent][] and you can read it here.

If you would like to raise an issue concerning somebody's conduct, please contact me directly via email: jason@jasono.co. If your issue is with me and you don't feel comfortable approaching me directly, please find someone you trust to approach me - I promise to listen and be responsive.

[Code of Conduct]: ./code-of-conduct.md
[Contributor Covenent]: https://www.contributor-covenant.org/