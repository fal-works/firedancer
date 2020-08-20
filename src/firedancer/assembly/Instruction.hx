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
	UseThread(programId: UInt, output: NullOrStack);
	AwaitThread;
	End(endCode: Int);
	// ---- move values ---------------------------------------------
	Load(input: ImmOrVar);
	Save(type: ValueType);
	Store(input: ImmOrReg, address: UInt);
	// ---- read/write stack ----------------------------------------
	Push(input: ImmOrReg);
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
	Add(inputA: RegOrVar, inputB: ImmOrReg);
	Sub(inputA: ImmOrReg, inputB: ImmOrReg);
	Minus(reg: DataRegisterSpecifier);
	Mult(regA: DataRegisterSpecifier, inputB: ImmOrReg);
	Div(inputA: ImmOrReg, inputB: ImmOrReg);
	Mod(inputA: ImmOrReg, inputB: ImmOrReg);
	CastIntToFloat;
	CastCartesian;
	CastPolar;
	RandomRatio;
	Random(max: ImmOrReg);
	RandomSigned(maxMagnitude: ImmOrReg);
	Sin;
	Cos;
	IncrementL(address: UInt);
	DecrementL(address: UInt);
	// ---- read actor data ------------------------------------------
	LoadTargetPositionV;
	LoadTargetXV;
	LoadTargetYV;
	LoadBearingToTargetV;
	CalcRelative(
		attrType: ActorAttributeType,
		cmpType: ActorAttributeComponentType,
		input: ImmOrReg
	);
	// ---- write actor data ------------------------------------------
	SetVector(
		attrType: ActorAttributeType,
		cmpType: ActorAttributeComponentType,
		input: ImmOrRegOrStack
	);
	AddVector(
		attrType: ActorAttributeType,
		cmpType: ActorAttributeComponentType,
		input: ImmOrRegOrStack
	);
}
