-- Worm Facts :: fact corpus
-- Pure data, no logic. Add as many as you want.
--
-- HARD RULE: each fact must fit in ONE whisper. WoW truncates SendChatMessage
-- at 255 characters. Aim for 180-250. Run "/wf lint" in game to find any
-- that are over the line -- the addon also refuses to send an oversized fact.
--
-- Style: name the animal, land the hook, then give the payoff. Two sentences
-- is usually right. Three if they're short. Goofier is better.
--
-- Plain ASCII only. Curly quotes, em dashes and accents can mangle in chat.
--
-- Categories are arbitrary; add your own and the addon picks them up.

WormFacts_Corpus = {

  ---------------------------------------------------------------------------
  -- Marine worms, who are carrying this entire addon
  ---------------------------------------------------------------------------
  marine = {
    "The bootlace worm may be the longest animal alive. A specimen that washed up in Scotland in 1864 was reported at 55 meters, longer than a blue whale, and it is about as thick as a shoelace.",

    "Bootlace worms coat themselves in mucus laced with a neurotoxin that paralyzes crustaceans. Researchers have been poking at it as a possible natural insecticide.",

    "Osedax worms live on whale skeletons on the seafloor and have no mouth, no gut, and no anus. They bore into the bone with acid and let symbiotic bacteria digest the fat and collagen inside.",

    "For years researchers only ever found female Osedax worms. The males turn out to be microscopic, never develop past a larval stage, and live dozens at a time inside the female's tube.",

    "One bone-eating worm is formally named Osedax mucofloris, which translates to bone-devouring snot-flower. The scientists who named it were not being subtle.",

    "Chaetopterus pugaporcinus is a deep sea worm shaped like a small pink sphere, drifting inside a cloud of its own mucus. The name means resembling a pig's rear, because it does.",

    "Ramisyllis multicaudata lives inside a sponge and branches like a tree: one head, hundreds of rear ends, guts forking at every junction. Nobody is quite sure how it manages to eat.",

    "A second branching worm was found in Japan and named Ramisyllis kingghidorahi, after the three-headed monster that fights Godzilla.",

    "Some syllid worms reproduce by growing a detachable rear end that sprouts its own eyes and its own brain, then swims off by itself to find a mate. The front half stays home.",

    "Swima worms carry glowing sacs near their heads. Threatened, one detaches and flares bright green, and the worm slips away while the predator investigates the light.",

    "Bermuda fireworms glow on a schedule: about three days after a full moon, 55 minutes after sunset. Columbus's crew logged a light in the water like a wax candle. It was probably these.",

    "Once a year on a lunar cue, palolo worms in Samoa release their own tails, which swim to the surface to spawn unsupervised. People paddle out with nets and eat them.",

    "The fat innkeeper worm digs a U-shaped burrow and spins a mucus net to catch food, ending up with crabs, fish and clams as lodgers. In Korea it is sold as gaebul and eaten while still moving.",

    "Bloodworms build their jaws out of protein reinforced with copper mined from the sediment they live in. The bite is venomous and the jaws last the worm's entire life.",

    "Kuphus polythalamia is a shipworm a meter and a half long that lives in foul mud. Nobody studied a live one until 2017. It has given up eating and lets sulfur bacteria feed it instead.",

    "Some cold-seep tube worms grow so slowly that individuals are estimated to be over 250 years old, putting them among the longest-lived animals known.",

    "Giant tube worms at hydrothermal vents grow two meters tall with no mouth and no digestive tract. Bacteria packed inside them build food out of hydrogen sulfide, which to almost everything else is poison.",

    "The Pompeii worm lives on deep sea chimneys with its tail in water near 80 Celsius and its head in water near 20. It wears a fleece of bacteria on its back that may be insulation.",

    "The bobbit worm buries its body in the seafloor, leaves only its jaws exposed, and snaps shut on passing fish fast enough to sometimes cut them in half.",

    "Christmas tree worms spend their entire adult life cemented into a coral head. The two spiral fans sticking out work as both gills and a net for catching plankton.",

    "The sea mouse is a worm that looks like a furry slipper. Its bristles are natural photonic crystals, and they shift light red to green to blue better than the optical fibers we manufacture.",

    "A ribbon worm can eat prey bigger than itself by turning a muscular tube inside out through its head and firing it at the target.",

    "Green spoonworm larvae have no sex until they settle. Land on open seafloor and you become a fat female; land on a female and you become a millimeter-long male living inside her.",

    "Ice worms live their entire lives inside glaciers, grazing algae in the snow. Warm them much past 5 Celsius and their cell membranes come apart, essentially dissolving the worm.",
  },

  ---------------------------------------------------------------------------
  -- Things called worms that are not worms
  ---------------------------------------------------------------------------
  misnomers = {
    "Ringworm is a fungus. Woodworm is a beetle. Inchworms and silkworms are caterpillars. Glowworms are usually beetle larvae. Almost nothing called a worm is actually one.",

    "Shipworms are not worms, they are clams with a tiny shell they use as a drill. They ate the bottoms out of wooden ships for centuries and nearly wrecked the Dutch sea defenses in the 1730s.",

    "Silkworms have been domesticated so thoroughly that the adult moths can no longer fly and the species does not exist in the wild. They are also caterpillars, not worms.",

    "Mealworms can eat polystyrene foam and survive on it, thanks to gut bacteria that break the stuff down. They are beetle larvae, so not worms, but it is a good trick regardless.",

    "Waxworms chew through polyethylene, the plastic carrier bags are made from. A beekeeper noticed after putting some in a plastic bag and finding holes in it within the hour.",

    "The glowworms that turn New Zealand's Waitomo caves into a fake night sky are fungus gnat larvae, and the glittering threads they dangle are sticky fishing lines.",

    "Velvet worms are not worms either. They are their own ancient group, they have legs, and they hunt by firing two jets of glue from nozzles beside the head.",

    "The Mongolian death worm is a cryptid said to kill with electricity and spit venom from a distance. Nobody has ever produced one. Expeditions keep going out to look anyway.",
  },

  ---------------------------------------------------------------------------
  -- Parasites, who have no manners
  ---------------------------------------------------------------------------
  parasites = {
    "A horsehair worm grows inside a cricket, then floods its brain with proteins that make it seek water and jump in. The worm swims out of the drowning cricket and carries on with its day.",

    "Leucochloridium invades a snail's eyestalks and pulses them in bright green bands until they look like wriggling caterpillars. Birds eat the eyestalks. That is precisely the plan.",

    "Lancet flukes steer ants up a grass stem at dusk and lock their jaws onto it so a grazing sheep will swallow them. If no sheep turns up by morning, the ant is released to go about its business.",

    "Four out of every five animals on Earth are nematodes. Not four out of five species. Four out of five individual animals.",

    "A nematologist wrote in 1914 that if everything but nematodes vanished, you could still make out the world in worms: mountains, rivers, and a ghostly film where every plant and person had been.",

    "Horsehair worms mate by tangling into knots so hopeless that the whole group is named after the Gordian knot.",

    "A tapeworm has no mouth and no gut. It hangs in the intestine absorbing food through its skin, and the beef tapeworm can reach ten meters while doing it.",

    "Guinea worm has gone from millions of cases a year to a handful, with no drug and no vaccine. People were simply taught to filter their drinking water.",

    "The traditional guinea worm treatment is to wind the emerging worm onto a stick, a few centimeters a day, for weeks. Some think this is where the snake-on-a-staff medical symbol came from.",

    "In some Japanese streams, crickets driven into the water by hairworms make up a large share of everything the local trout eat all year. The parasite is effectively feeding the river.",
  },

  ---------------------------------------------------------------------------
  -- Earthworm anatomy
  ---------------------------------------------------------------------------
  anatomy = {
    "Earthworms have no lungs. They breathe straight through their skin, which is the entire reason a worm has to stay damp and why one dries out and dies on hot pavement.",

    "An earthworm has five pairs of aortic arches squeezing blood along its body, which is where the old line about worms having five hearts comes from.",

    "Every earthworm is a hermaphrodite carrying both sets of reproductive organs. Two worms still need each other: they line up head to tail and swap sperm, and then both lay eggs.",

    "Earthworms have no eyes at all. Light-sensitive cells scattered through the skin are the only way a worm knows it has been caught out in the open.",

    "Earthworms have no teeth. They swallow grit and grind their food in a muscular gizzard, which is the same trick chickens use.",

    "An earthworm has no skeleton. It holds its shape with pressurized fluid in its body cavity and moves by squeezing that fluid around, gripping the soil with rows of tiny bristles.",

    "Instead of a pair of kidneys, an earthworm has tiny filtering organs called nephridia in nearly every one of its hundred-plus segments.",

    "Earthworm blood is red for the same reason yours is, hemoglobin, except in a worm it floats loose in the plasma instead of being packed into cells.",

    "Giant nerve fibers run the whole length of an earthworm. They are the reason a worm can rip itself back down its burrow the instant a beak touches it.",

    "The pale swollen band around an earthworm is the clitellum. It secretes a slime tube that slides forward off the worm, collecting eggs and sperm on the way, and seals into a cocoon.",

    "An earthworm can crawl backwards as easily as forwards. The waves of muscle simply run the other way.",

    "Baby earthworms hatch as tiny complete worms. No larva, no metamorphosis, just a very small worm that proceeds to get bigger.",
  },

  ---------------------------------------------------------------------------
  -- Behavior and the things people get wrong
  ---------------------------------------------------------------------------
  behavior = {
    "Cutting an earthworm in half does not give you two worms. The front half can sometimes regrow a tail. The tail half has no brain, no mouth and no heart, and simply dies.",

    "Worms coming up after rain are probably not drowning. They survive underwater for a long time. Wet ground is just the only time a worm can travel any real distance without drying out.",

    "In worm grunting, people drive a stake into the ground and rub it to bring worms boiling up to the surface. The best explanation is that the vibration feels exactly like an approaching mole.",

    "Nightcrawlers keep a permanent vertical burrow and come back to the same one for years. They graze the surface at night and drag leaves down to line the tunnel.",

    "Nightcrawlers court before they mate. A worm will visit a neighbor's burrow repeatedly over several nights before anything actually happens.",

    "Earthworms reliably learn to avoid the branch of a maze that ends in something unpleasant, which is not bad work for a brain the size of a pinhead.",

    "Asian jumping worms thrash like a snake and shed their own tails when you pick them up. A nightcrawler will never do this, which is how you learn you have an invasion.",

    "In a drought, some earthworms burrow deep, tie themselves into a knot, line the chamber with mucus and wait. They can hold that position for months.",

    "Grab a nightcrawler in its burrow and it anchors its bristles hard enough that a robin routinely ends up with half a worm. The worm regrows the tail.",

    "Earthworms are fussy eaters. Given a choice of leaves they consistently prefer some over others, and they have chemical sensors spread over their whole body to sort it out.",
  },

  ---------------------------------------------------------------------------
  -- Soil and why worms matter
  ---------------------------------------------------------------------------
  ecology = {
    "Darwin spent over forty years on earthworms and made them the subject of his final book in 1881. He estimated they pass roughly ten tons of soil per acre through their bodies every year.",

    "Darwin tested whether worms could hear by playing a bassoon at them, which they ignored completely. Then he set the pot on the piano and they reacted instantly to the vibration.",

    "Darwin worked out that worms quietly bury ruins. They undermine stones from below and cast soil on top until ancient pavements sink out of sight.",

    "Most earthworms in the northern US and Canada are invasive. Glaciers wiped out the natives, and European worms arrived later in ship ballast and potted plants.",

    "Invasive earthworms strip the spongy litter layer off northern forest floors. The wildflowers, tree seedlings and salamanders that depend on that layer go with it.",

    "Invasive jumping worms turn forest soil into loose pellets that look exactly like coffee grounds. Once a patch of ground looks like that, it generally stays that way.",

    "Worm castings carry measurably more plant-available nitrogen and phosphorus than the soil the worm swallowed. A worm is a machine for making dirt better at being dirt.",

    "A square meter of good pasture can hold several hundred earthworms. Their combined weight underground can exceed the weight of the livestock grazing on top of them.",

    "Vermicomposting uses red wigglers, not nightcrawlers. Red wigglers live in rotting matter and stay put. Nightcrawlers want deep soil and will spend the whole time trying to escape the bin.",

    "Because worms absorb whatever is in the soil directly through their skin, they get used as living instruments for testing contaminated ground.",
  },

  ---------------------------------------------------------------------------
  -- Records and extremes
  ---------------------------------------------------------------------------
  records = {
    "There are more than six thousand described species of earthworm, and Antarctica is the only continent without any native ones.",

    "Australia's giant Gippsland earthworm routinely passes a meter in length. It lives in deep permanent burrows and you can hear it moving underground as you walk over the top.",

    "The longest earthworm ever recorded was a South African giant earthworm measured at around six and a half meters.",

    "The Palouse giant earthworm was declared extinct, then turned up again decades later. It is ghost white, burrows meters down, and was reported to smell faintly of lilies.",

    "A nematode nicknamed the devil worm was pulled out of a South African gold mine 3.6 km underground, far below where anyone thought animals could live. It is named after Mephistopheles.",

    "In 2023 researchers thawed nematodes out of Siberian permafrost and watched them start moving again. The surrounding material dated to roughly 46,000 years old.",

    "Nematodes live in the Antarctic Dry Valleys, some of the emptiest soil on Earth. In places the entire ecosystem is a couple of worm species and whatever they can find to eat.",

    "Peanut worms yank their whole front end inside their body when startled, turning into a smooth featureless lump. In parts of China and Vietnam they are set in a savory jelly and eaten.",

    "A planarian flatworm cut into pieces regrows a complete worm from each piece, head included, which makes it one of the great workhorses of regeneration research.",

    "Medicinal leeches are cleared by the FDA as a medical device. Surgeons still use them to pull pooled blood out of reattached fingers and skin grafts.",
  },

  ---------------------------------------------------------------------------
  -- Worms and people
  ---------------------------------------------------------------------------
  culture = {
    "The World Worm Charming Championships are held in Cheshire every year. The record is 567 worms in thirty minutes, set in 2009 by a ten-year-old named Sophie Smith.",

    "Competitive worm charming has a rulebook. Three by three meter plot, thirty minutes, vibrate the ground however you like. Digging is banned and so is water or any other liquid.",

    "Worm grunting is a licensed profession. In Florida's Apalachicola National Forest you need a permit from the Forest Service before you can go out and charm worms for bait.",

    "The Diet of Worms, where Martin Luther refused to recant in 1521, has nothing to do with worms. Worms is a city on the Rhine and a diet is an assembly.",

    "In Old English, wyrm meant worm, serpent and dragon all at once. The dragon in Beowulf is a wyrm. The word only shrank down to the small squishy ones later.",

    "Harvesting nightcrawlers for bait is real work. Pickers walk damp fields after dark with lights on their heads, and a fast one can gather several thousand worms in a night.",

    "The computer worm is named after a program in a 1975 science fiction novel, The Shockwave Rider, in which a tapeworm program is turned loose in a network.",

    "Aristotle called earthworms the intestines of the earth. Darwin liked the phrase enough to quote it approvingly two thousand years later.",
  },

  ---------------------------------------------------------------------------
  -- C. elegans, one millimeter long, absurdly overqualified
  ---------------------------------------------------------------------------
  celegans = {
    "C. elegans is a soil worm one millimeter long and was the first multicellular animal to have its entire genome sequenced.",

    "An adult C. elegans hermaphrodite has exactly 959 body cells, and biologists have traced the complete ancestry of every single one from the fertilized egg.",

    "Every neural connection in C. elegans has been mapped: 302 neurons, roughly seven thousand synapses. It is still the only nervous system anyone has finished wiring up.",

    "Work on C. elegans has produced multiple Nobel Prizes, including the 2002 prize for working out how cells are programmed to kill themselves on schedule.",

    "Live C. elegans were aboard Columbia in 2003. Their containers survived the breakup and reentry, and the worms were recovered alive weeks afterwards.",

    "C. elegans can smell cancer. A Japanese company sells a screening test where worms are placed near a urine sample and scored on which way they crawl.",

    "C. elegans sleeps. It has a genuine quiescent state with a single neuron controlling it, which is why a worm with 302 neurons keeps showing up in sleep research.",

    "Planarians trained to a task and then decapitated still seem to show the training after regrowing a head. It was fringe science for decades until a careful replication in 2013.",

    "Thomas Hunt Morgan once cut a single flatworm into 279 pieces to find out what would happen. A great many of them grew back into entire worms.",
  },

  ---------------------------------------------------------------------------
  -- Worms of Azeroth. Classic-era lore; nothing here is Forever-specific.
  ---------------------------------------------------------------------------
  lore = {
    "Ouro, the sandworm beneath Ahn'Qiraj, is named for the ouroboros, the serpent eating its own tail. Apt for a boss whose entire fight is burrowing under the sand and resurfacing somewhere worse.",

    "A colossal worm that swims through sand beneath a desert temple and erupts under your feet is not a subtle reference. Ouro is Azeroth's Shai-Hulud, just without the spice.",

    "Nightcrawlers are a real item in Azeroth. Fifty fishing skill for ten minutes, stocked by fishing suppliers everywhere. The continent independently reinvented the bait shop.",

    "Azeroth's tackle box includes a lure called the Flesh Eating Worm. It raises your fishing skill exactly like the others. Nobody selling it seems troubled by the name.",

    "Wyrmthalak, down in Lower Blackrock Spire, is a dragon rather than a worm. That is not sloppy naming: in Old English, wyrm meant worm, serpent and dragon all at once, and Warcraft kept the older sense.",

    "The jormungar of Northrend are named for Jormungandr, the Norse serpent that circles the world biting its own tail. Between them and Ouro, Azeroth names its giant worms after the same myth twice.",

    "Silithids burrow, swarm, and erupt out of the sand exactly the way a giant worm would. They are insects. Azeroth has the same naming confusion we do, just at a more alarming scale.",

    "Worms are a tamable hunter pet family, which means somewhere out there is a hunter whose lifelong travelling companion is an enormous burrowing worm, and it has a name.",

    "The Plaguelands crawl with carrion grubs working through what the Scourge left behind. That part is ecologically sound. Worms are what happens to a corpse; Azeroth has only adjusted the scale.",

    "Opening the gates of Ahn'Qiraj took a server-wide war effort, tens of thousands of turned-in materials, all so everyone could go inside and fight an enormous worm and the things living behind it.",

    "Being among the first to ring the gong at Ahn'Qiraj earned a title and a mount that was never available again. The reward for waking the worms was permanent bragging rights.",

    "Bosses all over Azeroth use worm as an insult. Given that worms aerate the soil, build the topsoil and feed half the food web, this reflects worse on the bosses than it does on you.",

    "Ahn'Qiraj is a desert temple full of insects built on top of a sleeping Old God, and the giant worm is somehow not the strangest thing in there.",
  },
}
