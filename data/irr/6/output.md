## 1 \- 20:3314:338
 So my last question is, are there situations relating to unsafe code in the, I guess in any way that you've used it, or maybe in particular to the JIT stuff, or just your FFI usage, where you feel like a, like the current development tools you have can't solve this problem or this bug, and do you wish there was something that could?

***Participant***\
I mean, I definitely wish that verification to some extent was more fleshed out in Rust. You know, I've like, I've tried a bunch of the tools, l

## 2 \- 10:1718:44
in personal projects, some things might be unsafe, like, but that's most of my personal projects is the unsafe and my personal projects is to do with FFI.

**Interviewer**\
Gotcha, okay.

***Participant***\
Yeah. Yeah, I wouldn't be able to pinpoint like one or two discrete areas.

**Interviewer**\
Oh, okay. Gotcha. I guess more in terms of the documentation and the interfaces you're exposing to users then you mentioned earlier, like writing an unsafe interface or implementing a trait. Are you g

## 3 \- 17:2554:10
e invalidates your borrow stack. And I was like, oh my God, they're the same language, guys, you have to call address of with both. 
**Interviewer**\
Gotcha. Oh, this is interesting. Different reasons, but same practice.

***Participant***\
Yeah, totally funny. And I was like, that's a really easy guy. He's still kind of complaining about it. But I'm like, dude, it's just like C++, just call address of, dude. You don't have to understand it. You just call the function, you know, you need to call

## 4 \- 19:2774:301
ine having a very, very well encapsulated unsafe module, but one that is not resistant to change, at least do you feel that that's the case, that this concept of encapsulation and resistance to change, or do you feel that those are separate concepts in this case? Are there situations where you've seen unsafe that's well encapsulated, but that is somehow still too tied up or not as resistant to change as you might want it to be?

***Participant***\
I use resistance of change quite loosely. It's h

## 5 \- 7:995:75
in that case? So you're executing these intrinsics on the raw pointers you have under this wrapper? Or are there other situations where you use intrinsics?

***Participant***\
I use intrinsics because I develop on the standard library sometimes itself and that one built on intrinsics. The only other intrinsics that we've used were the volatile ones for the embedded project.

**Interviewer**\
Gotcha. And have there been memory safety challenges so far that have been unique to those intrinsics tha

## 6 \- 3:429:440
ould still take a lot more work in the C++ thing. The anecdote I have is when I was, there was this one big change I needed to make at one point that was across both Rust and C++ and I kind of predicted it would take me three or four days with like one day to do the Rust side, one day to do the C++ side, and one day to kind of make sure they're all aligned. It took me around two or three weeks and what happened was partly I had to figure out how to split it up into pieces so that the C++, so tha

## 7 \- 22:3522:16
sted in the survey in unsafe contexts. So I think I'll ask this a bit more broadly then.

***Participant***\
Oh yeah. Just remind me, I've been on a work trip for the last two weeks. So I completely lost all context.

**Interviewer**\
Yeah. So I guess the survey question was just which of the following reference and memory container types have you converted to raw pointers or used to contain raw pointers?

***Participant***\
Okay.

**Interviewer**\
You selected pretty much everything. So I was w

## 8 \- 28:4136:214
r**\
Yeah, sure.

***Participant***\
So it's referencing the other field. That while it's not, like, concretely self-referential in terms of this is now, like, an object where if you moved it, you'd get dangling pointers, it still doesn't get expressed well in rust. And so you can see stuff like the get to crate works around this by having just a kind of a shitload of lifetimes on everything. And, like, that's a great crate. And it's a really good approach. But it also is very hard to, like, put

## 9 \- 22:3387:3278
ne was significantly slower, right? Just because it was mostly wasteful of memory and then we're passing around all these reference types to make sure that things last as long as they should, so like arcs everywhere. Not great, right? We have, in these case, we have a variety of different types, high level types that represent a safely allocated and, you know, always actively mapped to real existing physical memory, regions of virtual memory that you can access. There's some types that represent

## 10 \- 7:1025:996
it'll just break randomly. And if you have an attacker who's sufficiently knowledgeable about your software, they will break it. So having used cases like that, it is only sound in practice because you don't have a sufficiently motivated attacker. But once you have someone with the motivation and the knowledge, then that becomes a problem. Yes, definitely. So in this, oh, sorry. Miri is just a really bad fuzzer. It's like, it's not a fuzzer, it does it done mystically, but it finds the same thin

## 11 \- 31:4368:877
to take seriously. Because what happened, I was like, I looked, I, I learned a little bit about WebAssembly, specifically the WebAssembly JavaScript boundary. It was really obvious to me why it's like this, because WebAssembly is very much like a virtual machine running in your browser with its own address space. And, and as, you know, an old school C/C++ developer, it was really obvious to me why I was like this. And then I was like, I just immediately realized that JavaScript calling Emscripte

## 12 \- 35:5311:86
re other projects where the JavaScript and Python?

***Participant***\
The test stuff had JavaScript and TypeScript. 

**Interviewer**\
Gotcha. 

***Participant***\
That was using WebAssembly.. So you have to pre-selfify there a WebAssembly module, just like some, let's call it some Wasm code, and the TypeScript or JavaScript calls into that. Yeah.

**Interviewer**\
And then with Python?

***Participant***\
I've run through examples with Python. I haven't actually programmed anything. So that se

## 13 \- 2:74:94
ou know, if there is only one thread, every single implementation of send and sync are sound because they have effectively no information.

**Interviewer**\
Yeah. So when you were calling to the UEFI runtime though, would you need to use unsafe for those calls, right? So were like, which data types did you generally pass to those functions? Was there an interaction between the Rust memory that you had and the UEFI run times access to that?

***Participant***\
No, not really. The UEFI run time, w

## 14 \- 31:4452:56
s. And I was like, as soon as I saw what the JavaScript web assembly boundary was like, I do not think it's going to be acceptable to have something crossing this all the time.

**Interviewer**\
And those are decisions you made based on your prior experience, but you didn't have any formal profiling or performance data with that.

***Participant***\
I knew that I was like, I do not want a situation where I press a button and the Web assembly JavaScript boundary is crossed 100 times, the user pre

## 15 \- 26:3943:1092
rs and various data types over them. We added a differential fuzzer, which will take code, execute it in the spec interpreter or something else and wasm time verify has the same results, which then added support for our fuzz case generation to generate stuff with SIMD instructions and then we just ran that through the fuzzer and it occasionally finds issues of like this lowering is a little buggy. Like when you have this kind of weird shape of module, it just has a compiler panic or it produces 

## 16 \- 26:3871:1468
ver the place, if that was actually an index within the store, then the layout of the store would have to be known to the JIT code. So it would say like the JIT code itself, when it access the store would do the bounds check would then index and do everything manually. So it's like, we couldn't write necessarily safe Rust code for that. Or rather, if we had Rust code, we'd have to like duplicate it in like [generator] machine code sort of. So these two are definitely intentional. We're like, numbe

## 17 \- 19:2918:382
thing because you're able to do more complex things. In saying that, do you mean that like, because there's like, because you're running in an interpreter, you already know that you're not going to be much faster than a certain baseline. So it's like more acceptable to do more expensive things because you aren't like, there isn't this expectation of performance. Would you say that that's correct? Or is there a different reason why you feel that?

***Participant***\
I think I said it in the wrong

## 18 \- 28:4040:141
wer**\
Okay. Sure. Yeah. So then another broad question, what do you use unsafe Rust for?

***Participant***\
Performance, FFI, implementing abstractions that you couldn't do in Safe Rust, like extending the language in ways that wouldn't quite work in Safe Rust. A lot of things kind of boiled down to different kinds of FFI, for example, different kinds of syscalls you might talk to the OS with, a little bit of control over data layout and accessing one type as another type. That kind of stuff i

## 19 \- 10:1958:256
ight have heard about Actix web. So there's a Actix web a couple of years ago. So the original author of Actix web kind of did a couple of dodgy things with unsafe. And, and then people saw like people made tickets about it. And like the whole thing turned into a bit of a witch hunt. And so the original author of Actix web basically abandoned the whole community. So Steve Klabnick has a really good blog post about it. I'll see if I can find it.

**Interviewer**\
Yeah, if you could get the link 

## 20 \- 37:5768:2014
ewer folks, because they don't realize at first that actually like this character struct has like this Rust extension struct packed onto the end of it. And they just look and see the C version and look at all the fields available and they're like, I don't see this field that I thought was here. And it's like, well, you can't hit it from C, you kind of have to go to the other language if you want to touch that data kind of thing.

**Interviewer**\
Yeah, gotcha. And have there been any particular 

## 21 \- 17:2384:701
 a raw pointer and participate in the ownership. So you have to have disparate allocations for the for the header where you keep in all the counts, and then for the object itself. But in Rust, you can't ever do that you you only create one allocation, whereas the frame or the header data embedded with the object. So in Rust, you see everyone leaking shared pointers everywhere. But in C++, we'd be like, you can hack it in with Boost. I've done that before, where Boost has like a little intrusive 

## 22 \- 35:5203:1187
in the type system. Luckily, global assembly, so the global assembly you can actually assign these registers values, mark them as an input or an output and continue on that way and then these safe abstractions around them would simply just be a function that it takes those parameters the normal way and returns the results normally.

**Interviewer**\
Yeah, gotcha. So, with the situation you're describing, is that where you'd use something like maybe an init, where you're like using return pointer

## 23 \- 3:546:993
ay have made mistakes. So you need to like find out their actual intent. This is often possible. Often there are just patterns where because we know how we know kind of how people think when it comes to code, we know what kinds of mistakes they make, so we can look at the mistake and be like, Oh, yeah, that's a common mistake. When you make this kind of mistake, your intent was almost certainly to do this, that you can do. The problem with unsafe is when you're when you're statically checking un

## 24 \- 17:2315:1327
eir aliasing rules. Yeah. But just because Miri's limited to the MIR, it's like you just can't use the tool at all. Not well, theoretically, if I was motivated enough, I think I could pull out segments of my code base and run Miri through a subset of the unit tests. But as terms of like a comprehensive, see, the problem with that is it leads to like an awkward constraint design, where sometimes you really just want to call the FFI function right as you're forming a mutable reference. I guess may

## 25 \- 2:95:63
restrictions, it's fairly easy to ... 

***Participant***\
Yeah, yeah.

**Interviewer**\
 ...safety or is, were there any challenges related to the use of those types?

***Participant***\
No, not at all. I mean, there are already some wrapper functions written around, but, and I use those where I could. In some cases, I couldn't. In some cases, I even just contributed the functions to the upstream implementation, I think. Maybe I didn't contribute them, I [unknown word] the project, I don't know

## 26 \- 17:2516:356
 was a little bit about me. I work for a nonprofit called the C++ Alliance. So we're basically paid staff to maintain boost libraries. So a big part of boost is, you know, we have like one of the biggest test matrices around. So one of the things is we have we have our own internal build called B2. So with B2, you can have it run like, like a product matrix of tests very easily. So if I want to write something in B2 to run, like, I'm like, okay, B2, I want you to run my tests. But I want you to 

## 27 \- 8:1383:67
okay can i just stare at this for another five minutes grab a coffee and then is that good enough so programmer laziness is um is yeah fights tooling unfortunately

***Participant***\
Can i ask uh yeah just what you're doing i'm assuming this is some related to your PhD project are you working in a group what are you what are you trying to accomplish because yeah i'm curious.

**Interviewer**\
Yeah, yeah, so um yeah so my my PhD is now centered on unsafe rust and i'm at the point where i sort of

## 28 \- 10:1949:164
demonized in a way. If that makes, I'm not sure if I'm quite make...

**Interviewer**\
No, no, you're, you're making perfect sense. Yeah, I'm totally following. Yeah. And I've, I think I've seen that that is as part of like the set of perspectives that people have on unsafe in prior interviews and engaging with the, with the community, like and on how that's, that's a one, one perception that people have. Yeah. 

***Participant***\
Yeah, you might remember.

**Interviewer**\
Sorry, you go. 

***

## 29 \- 6:562:803
up being like conceptualized in similar ways in C++ and Rust for like small tasks. But when you got to like larger structural problems, C++ kind of tends to like get this object oriented focus about it. You would want to like use polymorphism and virtual like make all your virtual functions and override them in your base classes in order to achieve like flexibility. And I think that was because using templates for a similar for like compile time. I'll call it compile time polymorphism, even thou

## 30 \- 7:776:60
ur unsafe usage was limited to taking a raw pointer in the beginning, converting that to a reference and to calling various volatile or atomic operations in those wrappers.

**Interviewer**\
Gotcha. So to clarify, you had a wrapper that had access to the underlying raw pointer and would perform the intrinsics on that representation. And then in cases where you'd expose that to safe Rust, you'd borrow against it. But you'd begin with like a raw pointer that you'd use for each of those operations.

## 31 \- 8:1380:935
in itself because lldb will work just fine but honestly i never remember all the arguments to it so yeah half of the time you'll just go okay can i just stare at this for another five minutes grab a coffee and then is that good enough so programmer laziness is um is yeah fights tooling unfortunately

***Participant***\
Can i ask uh yeah just what you're doing i'm assuming this is some related to your PhD project are you working in a group what are you what are you trying to accomplish because ye

## 32 \- 8:1152:144
to make. So I don't actually advocate documenting every piece of unsafe because of that.

**Interviewer**\
Gotcha. Interesting. Has there been a particular challenge you've run into with that where you've encountered a pattern that the community has seen that you feel that is something that should be avoided?

***Participant***\
I think I'm giving you a nugget of experience that I think transcends Rust or not Rust. Just when to comment and when not to comment. So step one, don't comment anything

## 33 \- 6:604:860
y. And so you can go from, you can take two pointers, you can find the offset between them without invoking undefined behavior. You can offset from one pointer to another, uh, and get to another place safely without invoking undefined behavior. And so one of the, uh, one of the interesting primitives that I built up was this, uh, in wrapper. It's under the mischief crate. There will be an instruct. And it's basically like a pin, but instead of saying this item is fixed in place, it's saying this

## 34 \- 28:4316:878
access to either like low level details or a more performant option with unsafe. And like, in particular, handing out the C objects that I won't give that as an unsafe function but I will give that give them the raw pointer to the C object and like, they're going to have to use unsafe to use that. Or perhaps the other way where I allow you to create a, a objective in the binding library from the raw pointer that it that has to be unsafe. And also probably that's like a bit of a headache because 

## 35 \- 6:580:315
 ways. The first is obviously to, you know, outsmart the compiler, squeeze a little more performance out. You know, when I know that certain invariants are met, I can use unsafe to speed up my code a bit and then wrap that in some sort of safer, larger abstraction. And then the other side of it is I use unsafe to construct new like compiler level, well, not compiler level, but to construct new language level primitives. So like if you're familiar with PIN, PIN uses a lot of unsafe, even though i

## 36 \- 7:929:37
are you in this case having to reason about lifetimes yourself when writing those wrappers and the inputs and outputs for those functions? Or do you have a heuristic that you use in doing that?

***Participant***\
Oh, no, you have to reason about it completely yourself. You need to look at the decode and figure out how those pointers relate to each other and then write those lifetimes manually.

**Interviewer**\
Gotcha. Have there been problems that you've encountered with doing that correctly? 

## 37 \- 9:1555:127
g and trying to create Rust bindings for it.

***Participant***\
Gotcha. Yeah. That's my question. Gotcha

**Interviewer**\
So you tend to write bindings yourself. Has that led to any problems relating to alignment or proper type usage when you write those bindings?

***Participant***\
I think I was concerned about this. So I was clear and that's why I didn't go that way because I tried to write bindings and I found there are so many complicated things I have to deal with. For example, the alloc

## 38 \- 8:1167:1578
e binary representation that you started with. That turns out that Python does it and a whole bunch of languages do it, Rust does it. So I solved that problem and that takes me another three weeks because of some threading constraints and I try to use the same libraries that Python does. And that turned out to be horribly unproductive. So from then on it's like, okay, fine, we now do this in Rust. What I was then able to do is expose the same C APIs. So that's where the initial bit of FFI was in

## 39 \- 19:2711:90
ay. Is there a particular example of something that you ran into as a limitation with safe Rust that you needed to use unsafe to get around?

***Participant***\
Yeah. One example, I haven't written that much unsafe code for a good reason. I've mostly just written it because I had an idea for fun. For example, one thing that I haven't quite written it myself, but I have reviewed it was rewriting the text pointer implementation inside rustc. Inside rustc there are some text pointers, an abstractio

## 40 \- 17:2519:797
orkspace, you can get you can have an outline through that, which is pretty convenient. I'm not really a huge fan of Rust’s fetish for like environment variables. But if you're setting environment variables in a config file, it's not really a big deal. You know, because like the cargo, the cargo configure whatever has like a dot ENV section where you can set everything. And I'm like, ah, that's okay. But I'm like, it's not as good as CMake's toolchain file.

**Interviewer**\
Gotcha.

***Particip

## 41 \- 19:2897:2816
d unsafe, that means the lint because realistically, if you're taking a raw pointer and dereference it, the function is to be unsafe because otherwise someone could just pass in a null pointer and then it's not good. Clippy also has an interesting one for signatures. If you have, if your function takes in a shared reference, but returns a mutable reference, it will lint because generally that's wrong because you can't just return a shared reference mutable reference. There are cases where it's c

## 42 \- 3:522:1925
on between l values and r values are what we call places and temporaries. But that distinction is basically internal. And you need to care about it in a couple places when it comes to borrowing. But the fixes are straightforward. So it's not it's not as in your face as it is in C++, where I've often had to think about these things. So that's like one difference. But overall, like the memory stuff is still similar, the way you deal with memory in Rust is very much inspired by the way people manua

## 43 \- 3:429:767
f make sure they're all aligned. It took me around two or three weeks and what happened was partly I had to figure out how to split it up into pieces so that the C++, so that if there was a memory safety error, I'd have a small amount of things to look at and partly it was actually chasing those down. What happened was like the Rust side was still easy, but the C++ side, every turn there were problems due to things I had not realized yet and some of this was because I was not an experienced pers

## 44 \- 20:3261:201
low JIT like folders hierarchy.

**Interviewer**\
Yeah. Gotcha, yeah, no, that's super helpful. Thanks a ton. Yeah, really appreciate it. So, I guess then let me double check this. So you've used also every development tool that I listed there. I guess could you describe then just the how bug finding tools fit into your development workflow with Rust?

***Participant***\
Yeah, I mean, Miri is incredibly helpful, you know, like it's a great diagnostic tool. Usually for a lot of them, I end up or 

## 45 \- 22:3453:225
Rust?

***Participant***\
So you don't have to do any of this, but I think in order to provide a truly bulletproof safe API around this inherently unsafe procedure of mapping and handling memory, it's nice to assert that these invariants are actually proven, enforce these invariants, rather. If you don't, you're offloading that onto somebody else. So that's what I would say many existing systems do written in unsafe languages. I mean, if you think about Linux or something, these guarantees don't

## 46 \- 26:3823:404
afe code. And that was actually very much motivated by last week, we had a CVE, just we had undefined behavior, one of our functions, which actually surfaced in real user behavior. So anyway, long story short, we were using Box of T for some data structures. We would say like, basically, we would put in a Box, which we would assume would heap allocated, we would then put the Box in the store, but then we retained pointers to it all over the place. So we wouldn't actually use the Box pointer. We 

## 47 \- 31:4610:376
er libraries, like the fact that, you know, Rust was, it's, Rust was almost just not a factor. It was like, I was debugging these open source libraries and seeing this malfunction and looking at, and looking at memory dumps and printfs to figure out when something changed and saw some classic C++ memory thrashing. And in some ways, the Rust stuff was as irrelevant as, you know, like the, you know, the build system was.

**Interviewer**\
Okay. So it's, it's, it's more that this error was just lik

## 48 \- 17:2504:1396
ike the data was set. It was just, it was given random bad values. And it was really funny because I saw the Azio author, he actually had run into the exact same bug I did. I saw the commit where he talked about it and I was like, that hit me too. I was like, oh my God, that's so funny.

**Interviewer**\
So now I learned set the user data to null manually, set it to null and then it'll come back correctly. Because I was relying on that. I was like, okay, I'm going to get a completion entry. The 

## 49 \- 22:3765:99
o I'm kind of hoping this will motivate more work and verification to hopefully help make better verification tools for for unsafe.

***Participant***\
Okay, great. Yeah, we're very interested in that that sort of thing.

## 50 \- 35:5398:110
use.

***Participant***\
You're looking for more, if I had a bug, how would I go around solving it? Is that what you want?

**Interviewer**\
Yeah, no, I mean that, but I'm also kind of curious about, like, what your process is to decide whether or not a crate is something that's good to use or not.

***Participant***\
Because like, so when you're, when you found that particular use case of mem uninitialized. That tells me that somebody either hasn't maintained the code or disabled the warning.



## 51 \- 3:537:337
ou listed in the survey. So you mentioned using both Miri and Clippy as well as a few of the sanitizers. Could you describe your experience using these tools and sort of compare and contrast them as well as the types of problems that you've found in in code bases using Rust or Rust and mixes of other languages?

***Participant***\
Yeah. Yeah, so Miri is great for looking for testing on safe code. I actually haven't had the time to write Miri tests for the zero copy digitalization things I've wri

## 52 \- 31:4539:562
top of those parameters. So I guess what happened is I created a bunch of wrappers for C++ code, just so that I'm not just randomly calling unsafe, you know, like get pointer, get length, and calling this other stuff. And in some cases, those wrappers themselves had caveats. And I just put big comments on them and said, when you use these wrappers, here are some caveats. Again, you know, compared to the C++ world, this is nothing. And then in the few places where I use those wrappers, which are 

## 53 \- 35:5179:550
 And then the job of that little bit of code is to bring the CPU into 64 bit mode eventually and load the rest of the operating system and let the operating system take over. So what I was doing here is working with like a nightly compiler with like a custom tool chain to get 16 bit code to be generated. And then using a small amount of global assembly to set up like an initial stack and then jump into some rest code that communicates with the BIOS disk drivers to read the next stage and then ju

## 54 \- 28:4316:418
s like yeah this is like something that starting up the library that's often just like yeah stuff is set up right in some ways like maybe this is going to map a file or something like yeah like make sure nobody's going to fuck with that file or something like that. Yeah, or you're only doing this once or something although that's something you could enforce but Yeah, so that's, but then it might not be the most efficient way to do it and then I'll do give access to either like low level details 

## 55 \- 32:4974:193
u have like other use cases for them?

***Participant***\
I mean, I have tried, maybe I tried to maybe use the team, increase, increase of vector just to help with resizing, you know, re-write structures if I have them. So I can use that to resize, at least that is.

**Interviewer**\
Gotcha. Gotcha. Yeah. And then, so you mentioned you doing FFI with Rust between C++ as well as JavaScript and TypeScript. Would you describe, like Rust has pretty particular assumptions that it makes about memory, 

## 56 \- 22:3578:16
t that by a VEC, but they're not on the heap. They're in hardware. 

**Interviewer**\
Right.

***Participant***\
And typically we have some of them use virtual addresses, some of them use physical addresses. 

**Interviewer**\
Right.

***Participant***\
So sometimes you need to go back and forth between virtual and grab it, grab the address that you passed in previously. You know, once the hardware says, hey, there's been a frame received at this point via DMA. 

**Interviewer**\
Right.

***Part

## 57 \- 35:5233:722
ip rules in that case. In, like, for some, like, writing to printed characters on the screen in its simplest form. There's old VGA drivers that have just the VGA text buffer in which you write ASCII characters and color attributes to a defined location of memory. And then that displays on the screen. This is like in the days of CRT monitors, so no, no monitor is going to be configured to do that right now, but it works just great in the virtual machine. But that's like just some location of all 

## 58 \- 17:2501:107
s kind of a downgrade, but then you use the PNG and then it has like long jump in it. And you're just like, uh, it's so hard.

**Interviewer**\
So speaking of difficult programming patterns, this next question is pretty broad again. Describe a bug that you face that involved unsafe Rust and sort of, if you can think of a particular example, go into how it manifested and then what the, what the fix was.

***Participant***\
Oh, man. This is funny. This is actually from liburing, the bug I encounte

## 59 \- 22:3441:1391
 set up an interrupt or something, right? You want to make sure that you're representing those correctly, but it's not necessarily unsafe if you don't represent them correctly. It's just, you know, wrong, right? So having something be wrong is not unsafe necessarily, but what we want to do with that is to make sure that, like, you know, the driver, for example, the timer device driver, whatever it is, the network device driver that is accessing those regions of memory is guaranteed that, you kno

## 60 \- 37:5582:1601
oved those from C headers into Rust headers, wrapped them all with some procedural macros and basically kept the ABI level stability. So the in-memory representation is the same, but we made those accessible to Rust and put Serde serializers and deserializers on top of them and deleted all the custom, like they had a custom .dat format that was like writing out keys and parsing values and just like every single data type had like a 300 line parser for a custom file format kind of thing. And we j

## 1 \- 35:5407:89
tcha. Yeah. So are you just like looking through the source code of dependencies that you choose and then auditing them for unsafe regularly?

***Participant***\
Occasionally I'll audit, occasionally I won't. If I'm interested in how something works, I'll take a peek, right?

**Interviewer**\
I see. And then when you're doing that sort of exploratory thing, that's when you start finding these cases.

***Participant***\
Yeah.

**Interviewer**\
What are some of the other patterns that you've seen 

## 2 \- 17:2641:421
ter. Because right now, you know, I've come to view rust as like a sort of like a two tiered language. In rust, you're one of two people you can either be trusted with unsafe or you're the forbid unsafe kind of person. So I think for people who actually write unsafe code, there's just so much work that needs to be done. Like the tooling is okay, you know, like you have sanitizers and whatnot, but it's just without a formally defined spec, it's, you're really just flying by the suit of your pants

## 3 \- 28:4166:658
 is note the case for SDL stuff. As soon as you have like a reference on it, you now need to track, as soon as you're doing reference counting where you have like the child object, not containing a lifetime to the parent. And you have to like make sure that one is not used on a different thread than the other, just a huge pain. Yeah.

**Interviewer**\
Gotcha. Gotcha. So is this, you're mentioning two patterns that seem to have different use cases where in some cases it's appropriate to use a lif

## 4 \- 2:239:873
e. So writing a safe wrapper for that would be pretty easy. You know, you just take a slice of a certain size and load the first whatever bytes. And if the slice is too short, that's an error. And you can also make the wrapper for a fixed size slice and all of that. And I guess you need to rely on the compiler to allow it to bounce checks at some point. Or you can do some equivalent of chunk smooth, I don't know. But you know, it's not super simple, but it should be relatively simple to make the

## 5 \- 6:706:240
cipant***\
Hmm. I would say that kind of, yes, I would say that it's really diverse, the kinds of memory safety errors that you can get, but there are like clumps. A really big clump is obviously like just good old fashioned. You mismanaged your pointers, uh, uh, you know, using the wrong pointer somewhere or using it after you should or leaving a dangling or, you know, all sorts of weird pointer errors. That's obviously a big clump of them. Uh, another kind of interesting clump, uh, is, uh, vio

## 6 \- 9:1639:48
e, in the read, update, and then just scan, etc. Yeah. And basically have a standard library, the oracle, the standard, the standard library B-Tree, and then compare the, their values.

**Interviewer**\
Gotcha. Nice. That's a really clever way of testing. So you also mentioned you have, so we spoke a bit about address sanitizer. You also use Clippy and memory sanitizer, at least you, you mentioned that your survey response. Have those tools been particularly useful for you?

***Participant***\
U

## 1 \- 31:4718:1168
 lot of, like, it was like I was proposing slaughtering children or something like this. It's like this phobia of undefined behavior is like so great that I'm like, and I'm thinking in my mind, like, I'm running in web assembly, I'm running in an environment hardened against malware. If I could go and get rid of my panics and save a few bytes, then I want to do so. And I get the benefit when I run my stuff on native code, which I'm doing anyway. And I just find it weird that there's this allergy

## 2 \- 3:465:142
aders and let you call them from Rust code. It does both ways, but it's for one language

***Participant***\
And the missing piece that I've noticed is there's not really a tool that, for the use case of I'm a library, I never want to call code that's not Rust, but I want everyone to talk to me. I don't want one language to talk to me. I want everyone to be able to use me as a library. And so there are now two tools that do this. There's one by Mozilla called UniFFI, where you kind of write thes

## 1 \- 31:4661:21
ewer**\
Gotcha. Was there like a particular pre and slash post condition that was, was the issue there?

***Participant***\
I think it had to do with me passing the alarm, reporting the alignment and passing it.

**Interviewer**\
Gotcha. So was it just like the wrong alignment value then?

***Participant***\
Yeah, I think, yeah, I think I, I think what I did is I had some code that, my code for figuring out that value was incorrect and I was passing some undefined value to it. And it worked most

## 2 \- 26:3841:1183
then every funkref for an instance is effectively [generator] plus a VM context. So it's kind of like a function pointer and the data for the function pointer, both of which are pointers. So for us, a funkref is a pointer to an in-memory data structure, which has two pointers, which is the function and the code. So that's like the basic data structure for this. So this means that my instance VM context, which has pointers, which has funkref inside of it, are all self-pointers. So all of those are 

