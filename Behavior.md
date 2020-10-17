## single animation, multiple triggers
- **Alert**
	- raid warning
	- paragon chest complete
	- received zone quest (legion/bfa assaults)
	- readycheck
	- role check
- **CheckingSomething**
	- encounter journal open
	- reading TRP/MRP
- **Congratulate**
	- raid boss kill
	- key timed
	- rare elite killed
	- received AH mail
	- quest completed
	- island finished
	- warfront complete
	- received achievement
	- reached reputation level
	- level up
	- resurrected
	- duel won
	- crafting complete
- **EmptyTrash**
	- died
	- key failed
	- raid boss wipe
	- duel lost
	- deleted item
- **Explain**
	- weakaura speech bubble (while idle)
- **GetAttention**
	- going afk
	- afk logout starts
- **GoodBye**
	- casting hearth
	- casting teleport
- **Greeting**
	- load
- **Hide**
	- cast invisibility
	- cast stealth
- **Print**
	- export WeakAura
- **Processing**
	- viewing LFG applicants
- **Searching**
	- viewing LFG groups
- **SendMail**
	- mail sent
	- trade complete
- **Show**
	- exit invisibility
	- exit stealth
	- cancel logout
- **Wave**
	- interact with frame

## single trigger, multiple animations
- Idle
	- *GetArtsy*
	- *GetAttention*
	- *Look`{direction}`*
	- *Print*
- Aggro drop (e.g. fade, feign death)
	1. *Hide*
	2. *Show*
- Pull timer
	1. *GetAttention*
	2. *Gesture`{direction}`* (towards center of screen)
	3. *Look`{direction}`* (towards center of screen)
- Log out (timer)
	1. *Wave1*
	2. *Save*
	3. *Print*
	4. *GoodBye*
