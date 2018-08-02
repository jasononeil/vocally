// Generated by Haxe 4.0.0-preview.4+1e3e5e0
(function () { "use strict";
var $hxEnums = {};
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var Example = function() { };
Example.main = function() {
	window.addEventListener("load",function() {
		var vocally1 = new vocally_Vocally();
		Example.setupEvents(vocally1);
		vocally1.say("Hello").pauseFor(1).say("my name is " + vocally1.synthesis.voice.name).say("But you can call me computer");
		vocally1.read(window.document.querySelector("article"));
		var current = window.document.querySelector("#current");
		return vocally1.onSpeak(function(u) {
			return current.innerText = u.text;
		});
	});
};
Example.setupEvents = function(vocally) {
	var btnPlayPause = window.document.querySelector("#btn_playpause");
	btnPlayPause.addEventListener("click",function() {
		return vocally.togglePlaying();
	});
};
var HxOverrides = function() { };
HxOverrides.substr = function(s,pos,len) {
	if(len == null) {
		len = s.length;
	} else if(len < 0) {
		if(pos == 0) {
			len = s.length + len;
		} else {
			return "";
		}
	}
	return s.substr(pos,len);
};
var haxe_Timer = function(time_ms) {
	var me = this;
	this.id = setInterval(function() {
		me.run();
	},time_ms);
};
haxe_Timer.delay = function(f,time_ms) {
	var t = new haxe_Timer(time_ms);
	t.run = function() {
		t.stop();
		f();
	};
	return t;
};
haxe_Timer.prototype = {
	stop: function() {
		if(this.id == null) {
			return;
		}
		clearInterval(this.id);
		this.id = null;
	}
	,run: function() {
	}
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	if(Error.captureStackTrace) {
		Error.captureStackTrace(this,js__$Boot_HaxeError);
	}
};
js__$Boot_HaxeError.wrap = function(val) {
	if((val instanceof Error)) {
		return val;
	} else {
		return new js__$Boot_HaxeError(val);
	}
};
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
});
var tink_core__$Callback_Callback_$Impl_$ = {};
tink_core__$Callback_Callback_$Impl_$.invoke = function(this1,data) {
	if(tink_core__$Callback_Callback_$Impl_$.depth < 1000) {
		tink_core__$Callback_Callback_$Impl_$.depth++;
		this1(data);
		tink_core__$Callback_Callback_$Impl_$.depth--;
	} else {
		var _e = this1;
		var f = function(data1) {
			tink_core__$Callback_Callback_$Impl_$.invoke(_e,data1);
		};
		var data2 = data;
		tink_core__$Callback_Callback_$Impl_$.defer(function() {
			f(data2);
		});
	}
};
tink_core__$Callback_Callback_$Impl_$.defer = function(f) {
	haxe_Timer.delay(f,0);
};
var tink_core__$Callback_LinkObject = function() { };
var tink_core__$Callback_ListCell = function(cb,list) {
	if(cb == null) {
		throw new js__$Boot_HaxeError("callback expected but null received");
	}
	this.cb = cb;
	this.list = list;
};
tink_core__$Callback_ListCell.__interfaces__ = [tink_core__$Callback_LinkObject];
var tink_core__$Callback_CallbackList_$Impl_$ = {};
tink_core__$Callback_CallbackList_$Impl_$.add = function(this1,cb) {
	var node = new tink_core__$Callback_ListCell(cb,this1);
	this1.push(node);
	return node;
};
tink_core__$Callback_CallbackList_$Impl_$.invoke = function(this1,data) {
	var _g = 0;
	var _g1 = this1.slice();
	while(_g < _g1.length) {
		var cell = _g1[_g];
		++_g;
		if(cell.cb != null) {
			tink_core__$Callback_Callback_$Impl_$.invoke(cell.cb,data);
		}
	}
};
var tink_core_SignalObject = function() { };
var tink_core_SignalTrigger = function() {
	this.handlers = [];
};
tink_core_SignalTrigger.__interfaces__ = [tink_core_SignalObject];
var vocally_Recognition = function() {
};
var vocally_Synthesis = function() {
	this.targetLength = 115;
	this.speechSynthesis = window.speechSynthesis;
	this.voice = this.getDefaultVoice();
	this.utterances = [];
	this.utterSignal = new tink_core_SignalTrigger();
};
vocally_Synthesis.splitStringIntoChunks = function(text,targetLength) {
	var fragments = [];
	while(text.length > targetLength) {
		var remainingText = text;
		var _g = 0;
		var _g1 = [".\"",".","!\"","!","?\"","?",";",":",",","\n\n","\n","\t"," "];
		while(_g < _g1.length) {
			var char = _g1[_g];
			++_g;
			var index = text.lastIndexOf(char,targetLength);
			if(index > -1) {
				fragments.push(HxOverrides.substr(text,0,index + char.length));
				remainingText = HxOverrides.substr(text,index + char.length,null);
				break;
			}
		}
		if(remainingText == text) {
			break;
		}
		text = remainingText;
	}
	fragments.push(text);
	return fragments;
};
vocally_Synthesis.prototype = {
	say: function(text,options) {
		var _gthis = this;
		var _g = 0;
		var _g1 = vocally_Synthesis.splitStringIntoChunks(text,this.targetLength);
		while(_g < _g1.length) {
			var fragment = _g1[_g];
			++_g;
			var utterance = [new SpeechSynthesisUtterance(fragment)];
			if(options != null) {
				if(options.lang != null) {
					utterance[0].lang = options.lang;
				}
				if(options.pitch != null) {
					utterance[0].pitch = options.pitch;
				}
				if(options.rate != null) {
					utterance[0].rate = options.rate;
				}
				if(options.voice != null) {
					utterance[0].voice = options.voice;
				}
				if(options.volume != null) {
					utterance[0].volume = options.volume;
				}
			} else {
				utterance[0].voice = this.voice;
			}
			var tmp = (function(utterance1) {
				return function() {
					tink_core__$Callback_CallbackList_$Impl_$.invoke(_gthis.utterSignal.handlers,utterance1[0]);
					return;
				};
			})(utterance);
			utterance[0].addEventListener("start",tmp);
			var pauseAndRestart = (function() {
				return function() {
					_gthis.speechSynthesis.pause();
					_gthis.speechSynthesis.resume();
				};
			})();
			this.utterances.push(utterance[0]);
			this.speechSynthesis.speak(utterance[0]);
		}
		return this;
	}
	,pauseFor: function(timeInSeconds) {
		var _gthis = this;
		var pause = new SpeechSynthesisUtterance("...");
		pause.volume = 0;
		pause.voice = this.voice;
		pause.addEventListener("start",function(e) {
			_gthis.speechSynthesis.pause();
			return window.setTimeout(function() {
				_gthis.speechSynthesis.resume();
				return;
			},Math.round(timeInSeconds * 1000));
		});
		this.utterances.push(pause);
		this.speechSynthesis.speak(pause);
		return this;
	}
	,read: function(element,options) {
		if(element == null) {
			return this;
		}
		var currentText = "";
		var _g = 0;
		var _g1 = element.childNodes;
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			var _g2 = child.nodeType;
			switch(_g2) {
			case 1:
				var childElement = child;
				var displayStyle = window.getComputedStyle(childElement).display;
				if(displayStyle == "inline" || displayStyle == "inline-block") {
					currentText += child.textContent + " ";
				} else {
					this.say(currentText,options);
					this.read(childElement);
					currentText = "";
				}
				break;
			case 3:
				currentText += child.textContent + " ";
				break;
			default:
			}
		}
		this.say(currentText,options);
		return this;
	}
	,onSpeak: function(cb) {
		tink_core__$Callback_CallbackList_$Impl_$.add(this.utterSignal.handlers,cb);
		return this;
	}
	,togglePlaying: function() {
		if(this.speechSynthesis.paused) {
			this.speechSynthesis.resume();
		} else {
			this.speechSynthesis.pause();
		}
		return this;
	}
	,getVoices: function() {
		return this.speechSynthesis.getVoices();
	}
	,getDefaultVoice: function() {
		var allVoices = this.getVoices();
		var _g = 0;
		while(_g < allVoices.length) {
			var voice = allVoices[_g];
			++_g;
			if(voice["default"]) {
				return voice;
			}
		}
		return allVoices[0];
	}
};
var vocally_Vocally = function() {
	this.synthesis = new vocally_Synthesis();
	this.recognition = new vocally_Recognition();
};
vocally_Vocally.prototype = {
	say: function(text,options) {
		this.synthesis.say(text,options);
		return this;
	}
	,pauseFor: function(timeInSeconds) {
		this.synthesis.pauseFor(timeInSeconds);
		return this;
	}
	,read: function(element,options) {
		this.synthesis.read(element,options);
		return this;
	}
	,togglePlaying: function() {
		this.synthesis.togglePlaying();
		return this;
	}
	,onSpeak: function(cb) {
		this.synthesis.onSpeak(cb);
		return this;
	}
};
Object.defineProperty(js__$Boot_HaxeError.prototype,"message",{ get : function() {
	return String(this.val);
}});
tink_core__$Callback_Callback_$Impl_$.depth = 0;
Example.main();
})();
