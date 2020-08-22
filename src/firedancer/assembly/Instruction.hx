package firedancer.assembly;

import firedancer.assembly.DataRegisterSpecifier;
import firedancer.assembly.Operand;
import firedancer.bytecode.types.FireArgument;
import firedancer.types.ActorAttributeType;
import firedancer.types.ActorAttributeComponentType;

@:using(firedancer.assembly.InstructionExtension)
enum Instruction {
	// ---- control flow --------------------------------------------
	Break;
	CountDownBreak;
	Label(labelId: UInt);
	GotoLabel(labelId: UInt);
	CountDownGotoLabel(labelId: UInt);
	UseThread(programId: UInt, output: Operand);
	AwaitThread;
	End(endCode: Int);
	// ---- move values ---------------------------------------------
	Load(input: Operand);
	Save(input: Operand);
	Store(input: Operand, address: UInt);
	// ---- read/write stack ----------------------------------------
	Push(input: Operand);
	Pop(type: ValueType);
	Peek(type: ValueType, bytesToSkip: Int);
	Drop(type: ValueType);
	// ---- fire ----------------------------------------------------
	FireSimple;
	FireComplex(fireArgument: FireArgument);
	FireSimpleWithCode(fireCode: Int);
	FireComplexWithCode(fireArgument: FireArgument, fireCode: Int);
	// ---- other ----------------------------------------------------
	GlobalEvent;
	LocalEvent;
	Debug(debugCode: Int);
	// ---- calc values ----------------------------------------------
	Add(input: OperandPair);
	Sub(input: OperandPair);
	Minus(input: Operand);
	Mult(inputA: Operand, inputB: Operand);
	Div(inputA: Operand, inputB: Operand);
	Mod(inputA: Operand, inputB: Operand);
	CastIntToFloat;
	CastCartesian;
	CastPolar;
	RandomRatio;
	Random(max: Operand);
	RandomSigned(maxMagnitude: Operand);
	Sin;
	Cos;
	IncrementVV(address: UInt);
	DecrementVV(address: UInt);
	// ---- read actor data ------------------------------------------
	LoadTargetPositionR;
	LoadTargetXR;
	LoadTargetYR;
	LoadBearingToTargetR;
	CalcRelative(
		attrType: ActorAttributeType,
		cmpType: ActorAttributeComponentType,
		input: Operand
	);
	// ---- write actor data ------------------------------------------
	SetVector(
		attrType: ActorAttributeType,
		cmpType: ActorAttributeComponentType,
		input: Operand
	);
	AddVector(
		attrType: ActorAttributeType,
		cmpType: ActorAttributeComponentType,
		input: Operand
	);
	None;
}
