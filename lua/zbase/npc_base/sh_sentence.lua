if SERVER then util.AddNetworkString("ZBaseAddCaption") end

local NPC 				= ZBaseNPCs["npc_zbase"]
ZBaseScriptedSentences 	= ZBaseScriptedSentences or {}

function NPC:ZBaseEmitScriptedSentence(sentence, pos, overrideTab, CRecipientFilter, callback)
	if !sentence then return end
	if !IsValid(self) || ( !self:IsAlive() ) then return end

	local sentTab = ZBaseScriptedSentences[ sentence ]
	if !sentTab then return end

	self:ZBaseStopScriptedSentence( true )

	self.FinishSentenceCallback = callback

	local stable = table.Copy( sentTab )
	local captions = stable.caption && stable.caption[ 1 ] || ""

	for i = 1, #stable.sound do
		local snd = stable.sound[i]
		local num = 1

		if istable( snd ) && isstring( snd[ 1 ] ) then
			num = math.random( 1, #snd )
			snd = snd[ num ]
		end

		local nextSTable = stable.sound[ _ + 1 ]

		local capOver = overrideTab && overrideTab[ snd ] && overrideTab[ snd ][ 2 ] && overrideTab[ snd ][ 2 ].caption

		if nextSTable && istable( nextSTable ) && nextSTable.caption then
			if istable( nextSTable.caption ) then
				captions = captions .. ( capOver && capOver[ num ] || nextSTable.caption[ num ] || "" )
			else
				captions = captions .. ( capOver || nextSTable.caption || "" )
			end
		end

		local sndOver = overrideTab && overrideTab[ snd ] && overrideTab[ snd ][ 1 ]

		sndOver = sndOver && ( istable( sndOver ) && sndOver[ math.random( 1, #sndOver ) ] || sndOver )
		snd = sndOver || snd
		stable.sound[ _ ] = snd
	end

	local ZBase_ASS_CurAudio = 1
	local ZBase_ASS_SoundLast = 0
	local ZBase_ASS_SoundDelay = 0

	local timerName = "ZBaseEmitSoundSentenceTimer" .. self:EntIndex()

	timer.Remove( timerName )

	if stable.caption then ZBaseAddCaption( true, captions, stable.caption[ 2 ], stable.level, pos ) end

	timer.Create( timerName, 0, 0, function()
		if !IsValid(self) || stable == nil || ( ZBase_ASS_CurAudio > #stable.sound ) then

			timer.Remove(timerName)

			ZBase_ASS_CurSound = 1
			if isfunction( callback ) then
				callback()
			end

			if IsValid(self) then
				self.FinishSentenceCallback = nil
			end

		return end

		if CurTime() - ZBase_ASS_SoundLast >= ZBase_ASS_SoundDelay then

			if ZBase_ASS_CurAudio <= #stable.sound then

				local snd = stable.sound[ZBase_ASS_CurAudio]

				if isnumber( snd ) || ( istable( snd ) && !isstring( snd[ 1 ] ) || snd[ 1 ] == "" ) || snd == "" then ZBase_ASS_CurAudio = ZBase_ASS_CurAudio + 1 return end

				local sndNext = stable.sound[ZBase_ASS_CurAudio + 1]
				local dur = nil

				sndNext = overrideTab && overrideTab[ snd ] && overrideTab[ snd ][ 2 ] || sndNext

				--if istable( snd ) then PrintTable(snd) end
				if isnumber( sndNext ) then
					dur = ZBaseSoundDuration( snd ) + sndNext
				elseif istable( sndNext ) && sndNext.dur then
					dur = ZBaseSoundDuration( snd ) + sndNext.dur
				else
					dur = ZBaseSoundDuration( snd )
				end

				self.m_sASSCurSentence = snd

				local channel = istable( sndNext ) && sndNext.channel || stable.channel
				local volume = istable( sndNext ) && sndNext.volume || stable.volume
				local level = istable( sndNext ) && sndNext.level || stable.level
				local flags = istable( sndNext ) && sndNext.flags || stable.flags
				local pitch = istable( sndNext ) && sndNext.pitch || stable.pitch
				local dsp = istable( sndNext ) && sndNext.dsp || stable.dsp
				local durFix = dur * ( ( pitch || 100 ) / 100 )
				dur = durFix > dur && durFix || durFix < dur && dur + durFix || dur

				self.EmittedSoundFromSentence = true
				self:EmitSound( snd, level, pitch, volume, channel, flags, dsp, CRecipientFilter )
				self.EmittedSoundFromSentence = nil

				ZBase_ASS_CurAudio = ZBase_ASS_CurAudio + 1
				ZBase_ASS_SoundDelay = dur
				ZBase_ASS_SoundLast = CurTime()
			end
		end
	end)
end

function NPC:ZBaseEmittingSentence()
	return timer.Exists( "ZBaseEmitSoundSentenceTimer" .. self:EntIndex())
end

function NPC:ZBaseStopScriptedSentence(fullstop)

	if self:ZBaseEmittingSentence() then
		timer.Remove( "ZBaseEmitSoundSentenceTimer" .. self:EntIndex() )

		if isfunction(self.FinishSentenceCallback) then
			self.FinishSentenceCallback()
		end

		if fullstop == true && self.m_sASSCurSentence != nil then
			self:StopSound( self.m_sASSCurSentence )
			self.m_sASSCurSentence = nil
		end
	end

end

if CLIENT then

	net.Receive( "ZBaseAddCaption", function(len, ply)
		local text = net.ReadString()
		local dur = net.ReadFloat()
		ZBaseAddCaption( nil, text, dur, nil, nil )
	end)

end