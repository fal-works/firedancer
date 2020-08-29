package firedancer.assembly;

import firedancer.assembly.Operand;
import firedancer.assembly.types.*;

@:using(firedancer.assembly.InstructionExtension)
@:using(firedancer.assembly.InstructionOptimizer)
@:using(firedancer.assembly.InstructionAssembler)
enum Instruction {
	// ---- control flow --------------------------------------------------------
	Break;
	CountDownBreak;
	Label(labelId: UInt);
	GotoLabel(labelId: UInt);
	CountDownGotoLabel(labelId: UInt);
	UseThread(programId: UInt, output: Operand);
	AwaitThread;
	End(endCode: Int);
	// ---- move values ---------------------------------------------------------
	Load(input: Operand);
	Save(input: Operand);
	// ---- variables -----------------------------------------------------------
	Let(varKey: String, type: ValueType);
	Store(input: Operand, varKey: String);
	Free(varKey: String, type: ValueType);
	// ---- read/write stack ----------------------------------------------------
	Push(input: Operand);
	Pop(type: ValueType);
	Peek(type: ValueType, bytesToSkip: Int);
	Drop(type: ValueType);
	// ---- fire ----------------------------------------------------------------
	Fire(fireType: FireType);
	// ---- other general -------------------------------------------------------
	Event(eventType: EventType);
	Debug(debugCode: Int);
	// ---- calc values ---------------------------------------------------------
	Add(input: OperandPair);
	Sub(input: OperandPair);
	Minus(input: Operand);
	Mult(inputA: Operand, inputB: Operand);
	Div(inputA: Operand, inputB: Operand);
	Mod(inputA: Operand, inputB: Operand);
	Cast(castType: CastOperationType);
	RandomRatio;
	Random(max: Operand);
	RandomSigned(maxMagnitude: Operand);
	Sin;
	Cos;
	Increment(address: String);
	Decrement(address: String);
	// ---- read actor data -----------------------------------------------------
	Get(property: ActorProperty);
	GetTarget(prop: TargetProperty);
	GetDiff(input: Operand, property: ActorProperty);
	// ---- write actor data ----------------------------------------------------
	Set(input: Operand, property: ActorProperty);
	Increase(input: Operand, property: ActorProperty);
	// ---- no effects ----------------------------------------------------------
	Comment(text: String);
	None;
}
