using FSO.SimAntics.Engine;
using FSO.Files.Formats.IFF.Chunks;

namespace FSO.SimAntics.Primitives
{
    public class VMDialogSemiGlobalStrings : VMPrimitiveHandler
    {
        public override VMPrimitiveExitCode Execute(VMStackFrame context, VMPrimitiveOperand args)
        {
            if (context.ScopeResource.SemiGlobal == null) return VMPrimitiveExitCode.GOTO_FALSE;
            return VMDialogPrivateStrings.ExecuteGeneric(context, args, context.ScopeResource.SemiGlobal.Get<STR>(301));
        }
    }
}
