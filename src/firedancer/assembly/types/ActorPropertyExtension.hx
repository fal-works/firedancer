package firedancer.assembly.types;

import firedancer.assembly.Opcode;

class ActorPropertyExtension {
	public static function getReadOpcode(_this: ActorProperty): Opcode {
		return Opcode.read(switch _this.type {
		case Position:
			switch _this.component {
			case Vector: LoadPositionR;
			case Length: LoadDistanceR;
			case Angle: LoadBearingR;
			}
		case Velocity:
			switch _this.component {
			case Vector: LoadVelocityR;
			case Length: LoadSpeedR;
			case Angle: LoadDirectionR;
			}
		case ShotPosition:
			switch _this.component {
			case Vector: LoadShotPositionR;
			case Length: LoadShotDistanceR;
			case Angle: LoadShotBearingR;
			}
		case ShotVelocity:
			switch _this.component {
			case Vector: LoadShotVelocityR;
			case Length: LoadShotSpeedR;
			case Angle: LoadShotDirectionR;
			}
		});
	}

	public static function getWriteOpcode(
		_this: ActorProperty,
		operationType: ActorPropertyOperationType,
		inputKind: OperandKind
	): Opcode {
		return Opcode.write(switch _this.type {
		case Position:
			switch _this.component {
			case Vector:
				switch operationType {
				case Set:
					switch inputKind {
					case Imm: SetPositionC;
					case Reg: SetPositionR;
					default: throw unsupported();
					}
				case Add:
					switch inputKind {
					case Imm: AddPositionC;
					case Reg: AddPositionR;
					case Stack: AddPositionS;
					default: throw unsupported();
					}
				}
			case Length:
				switch operationType {
				case Set:
					switch inputKind {
					case Imm: SetDistanceC;
					case Reg: SetDistanceR;
					default: throw unsupported();
					}
				case Add:
					switch inputKind {
					case Imm: AddDistanceC;
					case Reg: AddDistanceR;
					case Stack: AddDistanceS;
					default: throw unsupported();
					}
				}
			case Angle:
				switch operationType {
				case Set:
					switch inputKind {
					case Imm: SetBearingC;
					case Reg: SetBearingR;
					default: throw unsupported();
					}
				case Add:
					switch inputKind {
					case Imm: AddBearingC;
					case Reg: AddBearingR;
					case Stack: AddBearingS;
					default: throw unsupported();
					}
				}
			}
		case Velocity:
			switch _this.component {
			case Vector:
				switch operationType {
				case Set:
					switch inputKind {
					case Imm: SetVelocityC;
					case Reg: SetVelocityR;
					default: throw unsupported();
					}
				case Add:
					switch inputKind {
					case Imm: AddVelocityC;
					case Reg: AddVelocityR;
					case Stack: AddVelocityS;
					default: throw unsupported();
					}
				}
			case Length:
				switch operationType {
				case Set:
					switch inputKind {
					case Imm: SetSpeedC;
					case Reg: SetSpeedR;
					default: throw unsupported();
					}
				case Add:
					switch inputKind {
					case Imm: AddSpeedC;
					case Reg: AddSpeedR;
					case Stack: AddSpeedS;
					default: throw unsupported();
					}
				}
			case Angle:
				switch operationType {
				case Set:
					switch inputKind {
					case Imm: SetDirectionC;
					case Reg: SetDirectionR;
					default: throw unsupported();
					}
				case Add:
					switch inputKind {
					case Imm: AddDirectionC;
					case Reg: AddDirectionR;
					case Stack: AddDirectionS;
					default: throw unsupported();
					}
				}
			}
		case ShotPosition:
			switch _this.component {
			case Vector:
				switch operationType {
				case Set:
					switch inputKind {
					case Imm: SetShotPositionC;
					case Reg: SetShotPositionR;
					default: throw unsupported();
					}
				case Add:
					switch inputKind {
					case Imm: AddShotPositionC;
					case Reg: AddShotPositionR;
					case Stack: AddShotPositionS;
					default: throw unsupported();
					}
				}
			case Length:
				switch operationType {
				case Set:
					switch inputKind {
					case Imm: SetShotDistanceC;
					case Reg: SetShotDistanceR;
					default: throw unsupported();
					}
				case Add:
					switch inputKind {
					case Imm: AddShotDistanceC;
					case Reg: AddShotDistanceR;
					case Stack: AddShotDistanceS;
					default: throw unsupported();
					}
				}
			case Angle:
				switch operationType {
				case Set:
					switch inputKind {
					case Imm: SetShotBearingC;
					case Reg: SetShotBearingR;
					default: throw unsupported();
					}
				case Add:
					switch inputKind {
					case Imm: AddShotBearingC;
					case Reg: AddShotBearingR;
					case Stack: AddShotBearingS;
					default: throw unsupported();
					}
				}
			}
		case ShotVelocity:
			switch _this.component {
			case Vector:
				switch operationType {
				case Set:
					switch inputKind {
					case Imm: SetShotVelocityC;
					case Reg: SetShotVelocityR;
					default: throw unsupported();
					}
				case Add:
					switch inputKind {
					case Imm: AddShotVelocityC;
					case Reg: AddShotVelocityR;
					case Stack: AddShotVelocityS;
					default: throw unsupported();
					}
				}
			case Length:
				switch operationType {
				case Set:
					switch inputKind {
					case Imm: SetShotSpeedC;
					case Reg: SetShotSpeedR;
					default: throw unsupported();
					}
				case Add:
					switch inputKind {
					case Imm: AddShotSpeedC;
					case Reg: AddShotSpeedR;
					case Stack: AddShotSpeedS;
					default: throw unsupported();
					}
				}
			case Angle:
				switch operationType {
				case Set:
					switch inputKind {
					case Imm: SetShotDirectionC;
					case Reg: SetShotDirectionR;
					default: throw unsupported();
					}
				case Add:
					switch inputKind {
					case Imm: AddShotDirectionC;
					case Reg: AddShotDirectionR;
					case Stack: AddShotDirectionS;
					default: throw unsupported();
					}
				}
			}
		});
	}

	public static function getDiffOpcode(
		_this: ActorProperty,
		inputKind: OperandKind
	): Opcode {
		return Opcode.read(switch _this.type {
		case Position:
			switch _this.component {
			case Vector:
				switch inputKind {
				case Imm: GetDiffPositionCR;
				case Reg: GetDiffPositionRR;
				default: throw unsupported();
				}
			case Length:
				switch inputKind {
				case Imm: GetDiffDistanceCR;
				case Reg: GetDiffDistanceRR;
				default: throw unsupported();
				}
			case Angle:
				switch inputKind {
				case Imm: GetDiffBearingCR;
				case Reg: GetDiffBearingRR;
				default: throw unsupported();
				}
			}
		case Velocity:
			switch _this.component {
			case Vector:
				switch inputKind {
				case Imm: GetDiffVelocityCR;
				case Reg: GetDiffVelocityRR;
				default: throw unsupported();
				}
			case Length:
				switch inputKind {
				case Imm: GetDiffSpeedCR;
				case Reg: GetDiffSpeedRR;
				default: throw unsupported();
				}
			case Angle:
				switch inputKind {
				case Imm: GetDiffDirectionCR;
				case Reg: GetDiffDirectionRR;
				default: throw unsupported();
				}
			}
		case ShotPosition:
			switch _this.component {
			case Vector:
				switch inputKind {
				case Imm: GetDiffShotPositionCR;
				case Reg: GetDiffShotPositionRR;
				default: throw unsupported();
				}
			case Length:
				switch inputKind {
				case Imm: GetDiffShotDistanceCR;
				case Reg: GetDiffShotDistanceRR;
				default: throw unsupported();
				}
			case Angle:
				switch inputKind {
				case Imm: GetDiffShotBearingCR;
				case Reg: GetDiffShotBearingRR;
				default: throw unsupported();
				}
			}
		case ShotVelocity:
			switch _this.component {
			case Vector:
				switch inputKind {
				case Imm: GetDiffShotVelocityCR;
				case Reg: GetDiffShotVelocityRR;
				default: throw unsupported();
				}
			case Length:
				switch inputKind {
				case Imm: GetDiffShotSpeedCR;
				case Reg: GetDiffShotSpeedRR;
				default: throw unsupported();
				}
			case Angle:
				switch inputKind {
				case Imm: GetDiffShotDirectionCR;
				case Reg: GetDiffShotDirectionRR;
				default: throw unsupported();
				}
			}
		});
	}

	static function unsupported(): String
		return "unsupported operation.";
}

private enum abstract ActorPropertyOperationType(Int) {
	final Set;
	final Add;
}
