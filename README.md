# 🌟 Vajrzart: Your Friendly Neighborhood VPN Wizard 🧙‍♂️

> Because setting up WireGuard shouldn't feel like solving a Rubik's cube blindfolded! 🎯

## 🎭 What's This Sorcery?

Tired of manually configuring WireGuard like it's 1999? Say hello to **Vajrzart** - your automated WireGuard setup script that turns the painful process into a magical journey! 

```
                    ⚡ VAJRZART ⚡
        Making VPNs Great Again, One Peer at a Time
```

## 🚀 Features That'll Make You Go "Woohoo!"

- 🧙‍♂️ **Automagic Installation**: WireGuard appears faster than you can say "abracadabra"
- 🎯 **Zero Drama Setup**: Because life's already complicated enough
- 🎮 **Sweet TUI Interface**: Pretty dialogs because we're not savages
- 🔐 **Automatic Key Generation**: We're basically a key factory
- 🎪 **Peer Management**: Add peers like you're collecting Pokemon
- 🛡️ **Built-in Validation**: We catch mistakes so you don't have to
- 🎨 **Progress Bars**: Because watching paint dry is boring

## 🎪 Prerequisites

- Linux server (Ubuntu server preferably, because we're fancy like that)
- Root access (sudo powers activate! ✨)
- Basic ability to type commands (hunt-and-peck accepted)
- A sense of humor (optional but recommended)

## 🎮 How to Rock This Thing

### 1. Initial Setup
```bash
sudo ./vajrzart.sh
```
That's it! Just kidding, there's more, but the script handles it all! 

### 2. Adding Peers
```bash
sudo ./vajrzart.sh add
```
🎁 This magical incantation creates a treasure chest at `/home/{user}/.wireguard` containing:
- ✨ A shiny new config file (handle with care, it's precious!)
- 🧙‍♂️ A magical client setup script (because we're nice like that)

**Boom! New peer faster than you can say "Why is traditional VPN setup so painful?"**

### 3. Client-side Setup: The Final Quest! 🎮

Now comes the fun part - getting the goodies to your client:
1. 📦 Deliver the magical scrolls (config + setup script) to your peer
   - *Carrier pigeon optional but not recommended*
2. 🚀 On the client machine, unleash the magic:
   ```bash
   sudo ./vajrzart_client.sh (client_config).conf
   ```
3. 🎪 Sit back and watch the show!
   - Warning: May cause spontaneous outbursts of "Wow, that was easy!"
   - Side effects include: Secure connections and happy users

*Pro tip: Your IT friends might get jealous of how easy this was. Share the magic! ✨*

## 🎯 What It Does

1. Checks if you're worthy (root privileges)
2. Installs WireGuard if it's missing
3. Sets up your server config like a boss
4. Generates keys that would make encryption nerds proud
5. Configures networking (because packets need directions)
6. Adds peers with style and grace
7. Generate client-side config and setup script
8. Setup the VPN on the client side magically
9. Makes you coffee (just kidding, PR welcome)

## 🎨 Configuration Files

- Server config (also on the client): `/etc/wireguard/wg0.conf`
- Client configs: `/home/{user}/.wireguard/`
- Your sanity: Preserved ✨

## 🔥 Common Issues & Solutions

### "Help! Something went wrong!"
1. Did you run it as root? (sudo is your friend)
2. Is your system Ubuntu-based? (we're not wizards... well, actually...)
3. Did you follow the prompts? (they're there for a reason)
4. Did you read this README? (gotcha!)

### "It says 'command not found'"
```bash
chmod +x wajrgard.sh  # Make it executable, make it proud!
```

## 🎪 Contributors Welcome!

Found a bug? Want to add a feature? Can you make better jokes than these? Submit a PR!

## 🎯 License

Free as in "free pizza" (but please buy me a coffee if you like it)

## 🎨 Final Words

Remember: VPNs are like underwear - everyone needs them, but not everyone talks about them.

```
                            Stay Safe, Stay Connected!
                    💫 Some idiot trying to programm things 💫
```

---
*Made with 💖 and possibly too much caffeine*
