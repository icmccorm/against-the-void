## 1 \- 17:2559:12
l kind of complaining about it. But I'm like, dude, it's just like C++, just call address of, dude. You don't have to understand it. You just call the function, you know, you need to call and, you know, move on.

**Interviewer**\
Gotcha.

***Participant***\
So that was one of those things. I think I had bugs in my vector about that where I was binding references to get addresses and Miri was like, I can't do that.

**Interviewer**\
Interesting.

***Participant***\
Yeah, I haven't run into that p

## 2 \- 7:818:115
e. But in the end, that only made a bunch of very menial work simple. It did not help us with writing drivers at all.
s
**Interviewer**\
Gotcha. So could you describe a bit more about the second use of unsafe that you mentioned in implementing a multi-threaded application? Or no, multi-threaded primitives.

***Participant***\
Basically, we have a problem in the Rust compiler where locking is not the right kind of work that we need to protect our data that is accessed from multiple threads. If we 

## 3 \- 32:4839:397
t the critical sections of my code and then it's key for me to, you know, to look for the unnecessary or necessary points where I can use unsafe for us just to achieve fine-grained control over memory allocation or maybe do the occasional perform low-level optimizations. So it's important to profile and benchmark your code to ensure that, you know, the performance gains outweigh the risk associated with unsafe code just because it's unsafe, that's it. Yeah.

**Interviewer**\
So you mentioned lik

## 4 \- 20:3320:62
ility to express more, I guess, complicated, this like invariants that were required to be able to turn, like kind of hoist a lot of currently unsafe code into safe code.

**Interviewer**\
Like that would be. Provide like an example of what one of those invariants would be. Is this something like related to provenance, or is this something that's like more like domain specific invariant that you?

***Participant***\
I mean, probably like mostly provenance related stuff, or yeah, and probably mos

## 5 \- 10:1916:666
like binary compatible and so on. So there was a, yeah, if they hadn't tried to use that technique from C, which is just car pointer casting, if they tried to use something like the byte mark crate, or which would do the same operation correctly, like in a type safe way. Or if they'd just use serde and like serialize to bin code or JSON or whatever, like they wouldn't have had the issue.

**Interviewer**\
Yeah. Yeah. Actually, yeah, that makes sense. So then I guess with lints, the one bug findi

## 6 \- 2:347:8
raightforward because you are mostly just passing things with with strings?

***Participant***\
I'm pretty sure the idea, I'm sure there are some parts of the u fi specification that own the memory, but I haven't found them.

**Interviewer**\
Gotcha.

***Participant***\
So, you know, it's mostly Oh, yeah, pass a buffer in a length and I will fill the data in it and or the other way around. And so that's like pretty memory trivial, pretty trivial as far as memory models are so

**Interviewer**\
G

## 7 \- 39:5835:35
? 

***Participant***\
[redacted]

**Interviewer**\
Gotcha. And how long, like how many years have of development experience in general, would you say that you have? 

***Participant***\
[redacted]

**Interviewer**\
So how is that transition then to what you were using before Rust then to using Rust in your applications?

***Participant***\
I think transition was quite transformative. And okay, switching to Rust, maybe a hard task, I would say as per say, and I was so glad to have discovered Rus

## 8 \- 7:1013:410
ppy. If you introduced either of these tools later in the project, it becomes much more challenging to run your test suites with that or run it across your project. If you started from the beginning, you always making sure that already works with those tools. That's been the biggest hurdle that I've had so far with Miri. Again, since I'm working on it myself, most of the time when I had an issue, I just fixed it myself. So I didn't have that many issues that we're blocking. That's probably not r

## 9 \- 32:4773:54
\
Can you hear me? I think I'm having some ...

**Interviewer**\
Yeah, I think the end of your answer, it got cut off again, I think. Could you repeat that last answer? Sorry. 

***Participant***\
Oh, yeah. I mean, to document and maybe to communicate, maybe I have an example called documentation and I want to create someone or maybe someone we're working with, I can just create it with Rust. I think sometimes the people I work with, they just understand it better.

**Interviewer**\
Gotcha. Gotc

## 10 \- 37:5642:484
 and so like the in-game chat is mirrored to Discord and so like we've got a tokio runtime on the side with some channels that we use to like throw stuff back and forth. So I just moved, like I took the C main, oh well also like I redid the config system so like put the config in Rust instead of whatever was the nasty C like parsing of get up stuff. So like through clap and whatever at that and then toml config. So main is definitely in Rust now and just calls out to C at some point, but it's de

## 11 \- 39:5853:58
. So, come again? Yeah, I've used multiple languages. I've used Ruby, I've used JavaScript, I've used Java, Python, C++, C++, C. I've used multiple languages. Yeah, so, yeah.

**Interviewer**\
Gotcha. And then when you use unsafe Rust, what are you using it for then?

***Participant***\
Mostly it's for, maybe, web development or maybe, yeah, mostly web development.

**Interviewer**\
Gotcha. So is it that you were, I guess, so you're using Rust in these web applications, like where does the Rust 

## 12 \- 31:4670:495
e I was doing that, it's like, it just, like, I feel it's something like that in practice would not be useful because it's like, hey, I'm doing this thing once. And, and then once I get this code working right, it's I ignore it and for the rest of my life. And it's not this, I have a feeling that the way I might be a weirdo for you is that in the code base I've written, the unsafe Rust is this, like, I got it working and then, and then moved on. It's not this pervasive theme in my development. M

## 13 \- 10:1862:257
tracking and like printing out thing allocations, like whenever an allocation is done, that's for that's kind of like the printf style debugging. So it's quick and dirty. You know, it's only like 30 lines. Most of it can be generated by Rust analyzer anyway. If I needed to go any further, like if I had to troubleshoot like a fragmentation, like properly troubleshoot fragmentation or, you know, I wanted to find out where a particular thing was being allocated. I might start off with printf style 

## 14 \- 17:2390:1220
in Rust, what you do is you have to make a sound, it's very hard to make a sound interface around an unsafe thing in Rust, just because if you give up like a handle, like a little ray type in Rust, you have to code around aggressive dropping and aggressive forgetting.

***Participant***\
Like they found out that you could easily create leaks. And so they made forget and drop safe functions. So you have to be prepared for a user just randomly dropping and randomly forgetting whatever you hand the

## 15 \- 17:2596:898
t to Google. Let's actually call the DNS server. Let's actually like do the real stuff because, you know, users aren't going to be running hermetic little local host or using mocks, you know, like you actually need real world testing. So yeah, that would be the biggest. Oh, also in the ability to run builds as a product matrix, like I want to be able to test, you know, like give it a configuration. Here's the four sanitizer, like here's the three sanitizers you need to use. You know, when I run,

## 16 \- 2:47:298
uld say that the more interesting projects are the, well, in the embedded system, I used unsafe, which I guess is not super surprising. And in the image, the coding library, I also used unsafe. As far as I know, at least for my contributions, everything else is completely unsafe free. So specifically for that, there's not much to talk about. 

**Interviewer**\
Gotcha. So let's focus on those two projects then. When you used unsafe in each of those contexts, what was it for and which unsafe featu

## 17 \- 22:3387:131
 you would choose to use unsafe for something over a safe abstraction maybe to improve performance?

***Participant***\
Ah, yes. It's the vast majority in my specific case is the former where, so part of, I think part of like the charter of this project is to see to what, like, what's the fullest extent to which we can avoid unsafety, right? Yeah, of course, there are many, many cases where we cannot avoid it. There are definitely some cases where I have considered using unsafety either because 

## 18 \- 22:3689:4
t should never happen. So I guess that's another classification of use cases there. I'm preferring unsafety over a place where I could use an option, but it would be logically invalid for that option to ever not exist. So we don't use an option.

**Interviewer**\
Gotcha. Yeah, that's really interesting. I guess I have a couple sort of final questions. One thing I'm wondering about is with all of these raw pointer conversions, it seems like it could be really useful to have a tool like Miri worki

## 19 \- 35:5529:3
non-Rust development tools. So like a virtual machine with debugging support. Yeah, honestly, the Rust, the ecosystem around Rust tooling is just so fantastic. It's one of the reasons I love it. And if there's something missing, I'd just make it.

**Interviewer**\
Yeah, that's awesome.

***Participant***\
There's definitely stuff around, like some of the Wasm tooling isn't quite what I'd like it to be. So like programming for WebAssembly. Wasm-bindgen is pretty great, but doesn't yet cover all u

## 20 \- 10:1916:369
tever, like Rust is perfectly happy to do that sort of type punning. But there's no, there's no, like, lints or anything, because that's, that's on you. And I mean, the best solution is the byte mark crate is, because that will enforce it properly, like, it'll enforce that all of your fields are like binary compatible and so on. So there was a, yeah, if they hadn't tried to use that technique from C, which is just car pointer casting, if they tried to use something like the byte mark crate, or w

