package cocosim.matlab2IR;

import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.InvocationTargetException;
import java.nio.charset.StandardCharsets;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeProperty;
import org.antlr.v4.runtime.tree.ParseTreeWalker;
import org.antlr.v4.runtime.tree.TerminalNode;

import cocosim.emgrammar.EMBaseListener;
import cocosim.emgrammar.EMLexer;
import cocosim.emgrammar.EMParser;

/*################################################################################
#
# Installation script for cocoSim dependencies :
# - lustrec, zustre, kind2 in the default folder /tools/verifiers.
# - downloading standard libraries PP, IR and ME from github version of CoCoSim
#
# Author: Hamza BOURBOUH <hamza.bourbouh@nasa.gov>
#
# Copyright (c) 2019 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
#
################################################################################*/
public class EM2JSON {
	public static class JSONEmitter extends EMBaseListener {
		ParseTreeProperty<String> json = new ParseTreeProperty<String>();
		ParseTreeProperty<String> text = new ParseTreeProperty<String>();
		
		String getJSON(ParseTree ctx) { 
			String s = "";
			String tmp = json.get(ctx);
			if (tmp != null) s = tmp;
			return s; 
		}
		void setJSON(ParseTree ctx, String s) { json.put(ctx, s); }
		
		String getTreeText(ParseTree ctx) { 
			String s = "";
			String tmp = text.get(ctx);
			if (tmp != null) s = tmp;
			return s; 
		}
		void setTreeText(ParseTree ctx, String s) { text.put(ctx, s); }
		
		@Override
		public void exitEmfile(EMParser.EmfileContext ctx) {   
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			if(ctx.script() == null) {
				buf.append(Quotes("functions")+":[");
				int n = ctx.function().size();
				for (int i=0; i < n; i++){
					EMParser.FunctionContext fctx = ctx.function(i);
					buf.append(getJSON(fctx));
					if(i < n - 1) buf.append(",\n");
				}
				buf.append("]\n}");
			}else {
				buf.append(getJSON(ctx.script()));
				buf.append("\n}");
			}

			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}

		@Override
		public void exitScript(EMParser.ScriptContext ctx) {
			StringBuilder buf = new StringBuilder();

			buf.append(Quotes("type")+":"+Quotes("script"));
			buf.append(",\n");

			buf.append(Quotes("statements")+":["+getJSON(ctx.script_body()));
			buf.append("\n]");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}

		@Override
		public void exitFunction(EMParser.FunctionContext ctx) {
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("function"));
			buf.append(",\n");
			String functionName = ctx.ID().getText();
			buf.append(Quotes("name")+":"+Quotes(functionName));
			buf.append(",\n");

			String returns = "[]";
			if(ctx.func_output() != null) returns = getJSON(ctx.func_output()) ;
			buf.append(Quotes("return_params")+":"+returns);
			buf.append(",\n");

			String inputs = "[]";
			if(ctx.func_input() != null) inputs = getJSON(ctx.func_input()) ;
			buf.append(Quotes("input_params")+":"+inputs);
			buf.append(",\n");

			if(ctx.END() == null)
				buf.append(Quotes("has_END")+":false");
			else
				buf.append(Quotes("has_END")+":true");
			buf.append(",\n");
			
			buf.append(Quotes("statements")+":["+getJSON(ctx.body()));
			buf.append("\n]\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}

		@Override public void exitFunc_input(EMParser.Func_inputContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("[");
			for (int i=0;i < ctx.ID().size(); i++) {
				TerminalNode id = ctx.ID(i);
				buf.append(Quotes(id.getText()));
				if(i < ctx.ID().size()-1) buf.append(",");
			}
			buf.append("]");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}

		@Override public void exitFunc_output(EMParser.Func_outputContext ctx) {

			StringBuilder buf = new StringBuilder();
			buf.append("[");
			for (int i=0;i < ctx.ID().size(); i++) {
				TerminalNode id = ctx.ID(i);
				buf.append(Quotes(id.getText()));
				if(i < ctx.ID().size()-1) buf.append(",");
			}
			buf.append("]");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}


		@Override public void exitScript_body(EMParser.Script_bodyContext ctx) {
			if (ctx.script_body() != null){
				StringBuilder buf = new StringBuilder();
				buf.append(getJSON(ctx.script_body()));
				buf.append(",\n");
				buf.append(getJSON(ctx.statement()));
				setJSON(ctx, buf.toString());
			}
			else
				setJSON(ctx,getJSON(ctx.statement()));
			setTreeText(ctx, ctx.getText());
		}
		
		@Override public void exitBody(EMParser.BodyContext ctx) {
			if (ctx.body() != null){
				StringBuilder buf = new StringBuilder();
				buf.append(getJSON(ctx.body()));
				buf.append(",\n");
				buf.append(getJSON(ctx.body_item()));
				setJSON(ctx, buf.toString());
			}
			else
				setJSON(ctx,getJSON(ctx.body_item()));
			setTreeText(ctx, ctx.getText());
		}


		@Override public void exitBody_item(EMParser.Body_itemContext ctx) { 
			setJSON(ctx,getJSON(ctx.getChild(0)));
			setTreeText(ctx, ctx.getText());

		}

		
		@Override public void exitStatement(EMParser.StatementContext ctx) {
			setJSON(ctx,getJSON(ctx.getChild(0)));
			setTreeText(ctx, ctx.getText());
		}

		

		@Override public void exitExpression(EMParser.ExpressionContext ctx) {
			if (ctx.notAssignment()	 != null){
				setJSON(ctx,getJSON(ctx.notAssignment()));
			}
			else
				setJSON(ctx,getJSON(ctx.assignment()));
			setTreeText(ctx, ctx.getText());
		}

		@Override public void exitAssignment(EMParser.AssignmentContext ctx) {
			StringBuilder buf = new StringBuilder();
			StringBuilder tbuf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("assignment"));
			buf.append(",\n");
			buf.append(Quotes("operator")+":"+Quotes("="));
			buf.append(",\n");
			buf.append(Quotes("leftExp")+":"+getJSON(ctx.primaryExpression()));
			buf.append(",\n");
			buf.append(Quotes("rightExp")+":"+getJSON(ctx.notAssignment()));
			buf.append(",\n");
			tbuf.append(getTreeText(ctx.primaryExpression()) + " = " + getTreeText(ctx.notAssignment()));
			buf.append(Quotes("text")+":"+Quotes(tbuf.toString()));
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, tbuf.toString());

		}
//
		@Override public void exitNotAssignment_primaryExpression(EMParser.NotAssignment_primaryExpressionContext ctx) {
			setJSON(ctx,getJSON(ctx.primaryExpression()));
			setTreeText(ctx,getTreeText(ctx.primaryExpression()));
		}
//		
		@Override public void exitColonExpression(EMParser.ColonExpressionContext ctx) {
			binaryExpression( ctx,  "colonExpression");
		}
//
		@Override public void exitRelopOR(EMParser.RelopORContext ctx) { 
			binaryExpression( ctx,  "relopOR");
		}

		@Override public void exitRelopAND(EMParser.RelopANDContext ctx) { 
			binaryExpression( ctx,  "relopAND");
		}

		@Override public void exitRelopelOR(EMParser.RelopelORContext ctx) { 
			binaryExpression( ctx,  "relopelOR");
		}

		@Override public void exitRelopelAND(EMParser.RelopelANDContext ctx) {
			binaryExpression( ctx,  "relopelAND");
		}

		@Override public void exitRelopEQ_NE(EMParser.RelopEQ_NEContext ctx) {
			binaryExpression( ctx,  "relopEQ_NE");
		}

		@Override public void exitRelopGL(EMParser.RelopGLContext ctx) {
			binaryExpression( ctx,  "relopGL");
		}

		@Override public void exitPlus_minus(EMParser.Plus_minusContext ctx) {
			binaryExpression( ctx,  "plus_minus");
		}

		@Override public void exitMtimes(EMParser.MtimesContext ctx) {
			binaryExpression( ctx,  "mtimes");
		}

		@Override public void exitMrdivide(EMParser.MrdivideContext ctx) {
			binaryExpression( ctx,  "mrdivide");
		}

		@Override public void exitMldivide(EMParser.MldivideContext ctx) {
			binaryExpression( ctx,  "mldivide");
		}

		@Override public void exitMpower(EMParser.MpowerContext ctx) { 
			binaryExpression( ctx,  "mpower");
		}

		@Override public void exitTimes(EMParser.TimesContext ctx) {
			binaryExpression( ctx,  "times");
		}

		@Override public void exitRdivide(EMParser.RdivideContext ctx) {
			binaryExpression( ctx,  "rdivide");
		}

		@Override public void exitLdivide(EMParser.LdivideContext ctx) { 
			binaryExpression( ctx,  "ldivide");
		}

		@Override public void exitPower(EMParser.PowerContext ctx) { 
			binaryExpression( ctx,  "power");
		}

		

		@Override public void exitUnaryExpression(EMParser.UnaryExpressionContext ctx) {
			StringBuilder buf= new StringBuilder(), tbuf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("unaryExpression"));
			buf.append(",\n");

			String operator = null;
			operator = ctx.unaryOperator().getText();
			buf.append(Quotes("operator")+":"+Quotes(operator));
			buf.append(",\n");
			buf.append(Quotes("rightExp")+":"+getJSON(ctx.primaryExpression()));
			
			buf.append(",\n");
			tbuf.append(operator  + getTreeText(ctx.primaryExpression()));
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, tbuf.toString());
		}
//
		@Override public void exitPostfixExpression(EMParser.PostfixExpressionContext ctx) { 

				StringBuilder buf = new StringBuilder();
				buf.append("{");
				buf.append("\n");
				buf.append(Quotes("type")+":"+Quotes("transpose"));
				buf.append(",\n");

				String operator = ctx.getChild(1).getText();
				buf.append(Quotes("operator")+":"+Quotes(operator));
				
				buf.append(",\n");
				buf.append(Quotes("leftExp")+":"+getJSON(ctx.notAssignment()));
				
				buf.append(",\n");
				buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
				buf.append("\n}");

				setJSON(ctx, buf.toString());
				setTreeText(ctx, ctx.getText());
		}
//
		@Override public void exitPrimaryExpression(EMParser.PrimaryExpressionContext ctx) { 
			setJSON(ctx, getJSON(ctx.getChild(0)));
			setTreeText(ctx, getTreeText(ctx.getChild(0)));
		}
//
		@Override public void exitParenthesedExpression(EMParser.ParenthesedExpressionContext ctx){
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("parenthesedExpression"));
			buf.append(",\n");
			buf.append(Quotes("expression")+":"+getJSON(ctx.notAssignment()));
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}
		
		@Override public void exitIgnore_value(EMParser.Ignore_valueContext ctx) {
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("ignore_value"));
			buf.append(",\n");
			buf.append(Quotes("value")+":"+Quotes(ctx.getText()));
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}

		@Override public void exitConstant(EMParser.ConstantContext ctx) { 
			if (ctx.function_handle() != null){
				setJSON(ctx, getJSON(ctx.function_handle()));
			}else{
				StringBuilder buf = new StringBuilder();
				buf.append("{");
				buf.append("\n");
				//if (ctx.END() != null)
				//	buf.append(Quotes("type")+":"+Quotes("end"));
				//else
					buf.append(Quotes("type")+":"+Quotes("constant"));
				buf.append(",\n");
				String dataType = ConstantDataType(ctx);
				buf.append(Quotes("dataType")+":"+Quotes(dataType));
				buf.append(",\n");
				buf.append(Quotes("value")+":"+Quotes(ctx.getText()));
				buf.append(",\n");
				buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
				buf.append("\n}");
				setJSON(ctx, buf.toString());
			}
			setTreeText(ctx, ctx.getText());
		}

		public String ConstantDataType(EMParser.ConstantContext ctx){
			String t = "";
			if (ctx.Integer() != null)
				t = "Integer";
			else if (ctx.Float() != null)
				t = "Float";
			//else if (ctx.END() != null)
			//	t = "Integer";
			else if (ctx.string() != null)
				t = "String";
			return t;
		}

		@Override public void exitFunction_handle(EMParser.Function_handleContext ctx) { 
			if (ctx.func_input() != null){
				StringBuilder buf = new StringBuilder();
				buf.append("{");
				buf.append("\n");
				buf.append(Quotes("type")+":"+Quotes("function_handle"));
				buf.append(",\n");
				buf.append(Quotes("input_params")+":"+ getJSON(ctx.func_input()));
				if (ctx.expression() != null){
					buf.append(",\n");
					buf.append(Quotes("expression")+":"+ getJSON(ctx.expression()));
				}
				buf.append(",\n");
				buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
				buf.append("\n}");
				setJSON(ctx, buf.toString());
			}else{
				StringBuilder buf = new StringBuilder();
				buf.append("{");
				buf.append("\n");
				buf.append(Quotes("type")+":"+Quotes("function_handle"));
				buf.append(",\n");
				buf.append(Quotes("ID")+":"+Quotes(ctx.ID().getText()));
				buf.append(",\n");
				buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
				buf.append("\n}");
				setJSON(ctx, buf.toString());
			}
			setTreeText(ctx, ctx.getText());
		}

		@Override public void exitFun_indexing(EMParser.Fun_indexingContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("fun_indexing"));
			buf.append(",\n");
			if (ctx.ID() != null)
				buf.append(Quotes("ID")+":"+Quotes(ctx.ID().getText()));
			else{
				// case of cell indexing in the left
				buf.append(Quotes("ID")+":"+getJSON(ctx.cell_indexing()));
			}
				
			buf.append(",\n");
			if (ctx.getChild(2).getText().equals(")"))
				buf.append(Quotes("parameters")+":"+"[]");
			else
				buf.append(Quotes("parameters")+":"+getJSON(ctx.getChild(2)));
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}
		@Override public void exitCell_indexing(EMParser.Cell_indexingContext ctx) { 
			StringBuilder buf = new StringBuilder(), tbuf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("cell_indexing"));
			buf.append(",\n");
			buf.append(Quotes("ID")+":"+Quotes(ctx.ID().getText()));
			tbuf.append(ctx.ID().getText());
			buf.append(",\n");
			int n = ctx.function_parameter_list().size();
			for(int i=0; i<n; i++) {
				buf.append(Quotes("parameters"+Integer.toString(i))+":"+getJSON(ctx.function_parameter_list(i)));
				buf.append(",\n");
				tbuf.append("{" + getTreeText(ctx.function_parameter_list(i)) + "}");
			}

			if (n == 0) buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(tbuf.toString()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, tbuf.toString());
		}
		

		@Override public void exitStruct_indexing_expr(EMParser.Struct_indexing_exprContext ctx){
			StringBuilder buf = new StringBuilder(), tbuf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("struct_indexing"));
			buf.append(",\n");
			buf.append(Quotes("leftExp")+":"+getJSON(ctx.struct_indexing(0)));
			buf.append(",\n");
			buf.append(Quotes("rightExp")+":"+getJSON(ctx.struct_indexing(1)));
			buf.append(",\n");
			tbuf.append(getTreeText(ctx.struct_indexing(0)) + "." + getTreeText(ctx.struct_indexing(1)));
			buf.append(Quotes("text")+":"+Quotes(tbuf.toString()));
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, tbuf.toString());
		}
		@Override public void exitS_fun_indexing(EMParser.S_fun_indexingContext ctx){
			setJSON(ctx, getJSON(ctx.fun_indexing()));
			setTreeText(ctx, getTreeText(ctx.fun_indexing()));
		}
		@Override public void exitS_cell_indexing(EMParser.S_cell_indexingContext ctx){
			setJSON(ctx, getJSON(ctx.cell_indexing()));
			setTreeText(ctx, getTreeText(ctx.cell_indexing()));
		}
		@Override public void exitS_parenthesedExpression(EMParser.S_parenthesedExpressionContext ctx){
			setJSON(ctx, getJSON(ctx.parenthesedExpression()));
			setTreeText(ctx, getTreeText(ctx.parenthesedExpression()));
		}
		@Override public void exitS_id(EMParser.S_idContext ctx){
			setJSON(ctx, getIdJson(ctx.ID().getText()));
			setTreeText(ctx, ctx.ID().getText());
		}

		String getIdJson(String text){
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("ID"));
			buf.append(",\n");
			buf.append(Quotes("name")+":"+Quotes(text));
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(text));
			buf.append("\n}");
			return buf.toString();
		}
		
		@Override public void exitFunction_parameter_list(EMParser.Function_parameter_listContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("[");
			int n = ctx.function_parameter().size();
			for (int i=0;i < n; i++) {
				EMParser.Function_parameterContext pctx = ctx.function_parameter(i);
				buf.append(getJSON(pctx));
				if(i < n-1) buf.append(",");
			}
			buf.append("]");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}

		@Override public void exitFunction_parameter(EMParser.Function_parameterContext ctx) { 
			if (ctx.COLON() == null)
				setJSON(ctx,getJSON(ctx.getChild(0)));
			else{
				StringBuilder buf = new StringBuilder();
				buf.append("{");
				buf.append("\n");
				buf.append(Quotes("type")+":"+Quotes("COLON"));
				buf.append(",\n");
				buf.append(Quotes("value")+":"+Quotes(ctx.COLON().getText()));
				buf.append(",\n");
				buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
				buf.append("\n}");
				setJSON(ctx, buf.toString());
			}
			setTreeText(ctx, ctx.getText());
		}

		@Override public void exitCell(EMParser.CellContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("cell"));
			buf.append(",\n");
			buf.append(Quotes("rows")+":[");
			int n = ctx.horzcat().size();
			for (int i=0;i < n; i++) {
				EMParser.HorzcatContext vctx = ctx.horzcat(i);
				buf.append(getJSON(vctx));
				if(i < n-1) buf.append(",");
			}
			buf.append("]");
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}

		@Override public void exitHorzcat(EMParser.HorzcatContext ctx) { 
			StringBuilder buf = new StringBuilder(), tbuf = new StringBuilder();
			buf.append("[");
			int n1 = ctx.notAssignment().size();
			int n2 = ctx.primaryExpression().size();
			//System.out.println("safs: "+ ctx.getText());
			
			if (n1 > 0) {
				
				for (int i=0;i < n1; i++) {
					EMParser.NotAssignmentContext vctx = ctx.notAssignment(i);
					
					buf.append(getJSON(vctx));
					tbuf.append(getTreeText(vctx));
					if(i < n1-1) {
						buf.append(",");
						tbuf.append(", ");
					}
				}
				
				
			}
			else {
				
				for (int i=0;i < n2; i++) {
					EMParser.PrimaryExpressionContext vctx = ctx.primaryExpression(i);
					buf.append(getJSON(vctx));
					tbuf.append(getTreeText(vctx));
					if(i < n2-1) {
						buf.append(",");
						tbuf.append(", ");
					}
				}
			}
			
			buf.append("]");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, tbuf.toString());
		}

		@Override public void exitMatrix(EMParser.MatrixContext ctx) { 
			StringBuilder buf = new StringBuilder(), tbuf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("matrix"));
			buf.append(",\n");
			buf.append(Quotes("rows")+":[");
			int n = ctx.horzcat().size();
			tbuf.append("[");
			for (int i=0;i < n; i++) {
				EMParser.HorzcatContext vctx = ctx.horzcat(i);
				buf.append(getJSON(vctx));
				tbuf.append(getTreeText(vctx));
				if(i < n-1) {
					buf.append(",");
					tbuf.append("; ");
				}
				
			}
			buf.append("]");
			tbuf.append("]");
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(tbuf.toString()));
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, tbuf.toString());
		}
//
		@Override public void exitIf_block(EMParser.If_blockContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("if_block"));
			buf.append(",\n");
			buf.append(Quotes("condition")+":"+getJSON(ctx.notAssignment()));
			buf.append(",\n");
			buf.append(Quotes("statements")+":["+getJSON(ctx.body()));
			buf.append("\n],\n");
			buf.append(Quotes("elseif_blocks")+":[");
			int n = ctx.elseif_block().size();
			for (int i=0;i < n; i++) {
				EMParser.Elseif_blockContext tctx = ctx.elseif_block(i);
				buf.append(getJSON(tctx));
				if(i < n-1) buf.append(",");
			}
			buf.append("\n],\n");
			if (ctx.else_block() == null) 
				buf.append(Quotes("else_block")+":{}");
			else 
				buf.append(Quotes("else_block")+":"+getJSON(ctx.else_block()));
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}
//
		@Override public void exitElseif_block(EMParser.Elseif_blockContext ctx) {
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("elseif_block"));
			buf.append(",\n");
			buf.append(Quotes("condition")+":"+getJSON(ctx.notAssignment()));
			buf.append(",\n");
			buf.append(Quotes("statements")+":["+getJSON(ctx.body()));
			buf.append("\n]");
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}
		@Override public void exitElse_block(EMParser.Else_blockContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("else_block"));
			buf.append(",\n");
			buf.append(Quotes("statements")+":["+getJSON(ctx.body()));
			buf.append("\n]");
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}

		@Override public void exitSwitch_block(EMParser.Switch_blockContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("switch_block"));
			buf.append(",\n");
			buf.append(Quotes("expression")+":"+getJSON(ctx.notAssignment()));
			buf.append(",\n");
			buf.append(Quotes("case_blocks")+":[");
			int n = ctx.case_block().size();
			for (int i=0;i < n; i++) {
				EMParser.Case_blockContext tctx = ctx.case_block(i);
				buf.append(getJSON(tctx));
				if(i < n-1) buf.append(",");
			}
			buf.append("\n],\n");
			if (ctx.otherwise_block() == null) 
				buf.append(Quotes("otherwise_block")+":{}");
			else 
				buf.append(Quotes("otherwise_block")+":"+getJSON(ctx.otherwise_block()));
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}

		@Override public void exitCase_block(EMParser.Case_blockContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("case_block"));
			buf.append(",\n");
			buf.append(Quotes("expression")+":"+getJSON(ctx.notAssignment()));
			buf.append(",\n");
			buf.append(Quotes("statements")+":["+getJSON(ctx.body()));
			buf.append("\n]");
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}

		@Override public void exitOtherwise_block(EMParser.Otherwise_blockContext ctx) {
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("otherwise_block"));
			buf.append(",\n");
			buf.append(Quotes("statements")+":["+getJSON(ctx.body()));
			buf.append("\n]");
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}

		@Override public void exitFor_block(EMParser.For_blockContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("for_block"));
			buf.append(",\n");
			buf.append(Quotes("index")+":"+Quotes(ctx.ID().getText()));
			buf.append(",\n");
			buf.append(Quotes("index_expression")+":"+getJSON(ctx.notAssignment()));
			buf.append(",\n");
			buf.append(Quotes("statements")+":["+getJSON(ctx.body()));
			buf.append("\n]");
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}

		@Override public void exitWhile_block(EMParser.While_blockContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("while_block"));
			buf.append(",\n");
			buf.append(Quotes("condition")+":"+getJSON(ctx.notAssignment()));
			buf.append(",\n");
			buf.append(Quotes("statements")+":["+getJSON(ctx.body()));
			buf.append("\n]");
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}

		@Override public void exitTry_catch_block(EMParser.Try_catch_blockContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("try_catch_block"));
			buf.append(",\n");
			buf.append(Quotes("statements")+":["+getJSON(ctx.body()));
			buf.append("\n],\n");
			if (ctx.catch_block() == null) 
				buf.append(Quotes("catch_block")+":{}");
			else 
				buf.append(Quotes("catch_block")+":"+getJSON(ctx.catch_block()));
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}
		@Override public void exitCatch_block(EMParser.Catch_blockContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("catch_block"));
			buf.append(",\n");
			if (ctx.ID() == null) 
				buf.append(Quotes("id")+":{}");
			else 
				buf.append(Quotes("id")+":"+getJSON(ctx.ID()));
			buf.append(",\n");
			buf.append(Quotes("statements")+":["+getJSON(ctx.body()));
			buf.append("\n]");

			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}
		@Override public void exitReturn_exp(EMParser.Return_expContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("return_exp"));
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}
		@Override public void exitBreak_exp(EMParser.Break_expContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("break_exp"));
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}
		@Override public void exitContinue_exp(EMParser.Continue_expContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("continue_exp"));
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}
		@Override public void exitGlobal_exp(EMParser.Global_expContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("global_exp"));
			buf.append(",\n");
			buf.append(Quotes("IDs")+":[");
			for (int i=0;i < ctx.ID().size(); i++) {
				TerminalNode id = ctx.ID(i);
				buf.append(Quotes(id.getText()));
				if(i < ctx.ID().size()-1) buf.append(",");
			}
			buf.append("]");
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}
		@Override public void exitPersistent_exp(EMParser.Persistent_expContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("persistent_exp"));
			buf.append(",\n");
			buf.append(Quotes("IDs")+":[");
			for (int i=0;i < ctx.ID().size(); i++) {
				TerminalNode id = ctx.ID(i);
				buf.append(Quotes(id.getText()));
				if(i < ctx.ID().size()-1) buf.append(",");
			}
			buf.append("]");
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}
		@Override public void exitClear_exp(EMParser.Clear_expContext ctx) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes("clear_exp"));
			buf.append(",\n");
			buf.append(Quotes("IDs")+":[");
			for (int i=0;i < ctx.ID().size(); i++) {
				TerminalNode id = ctx.ID(i);
				buf.append(Quotes(id.getText()));
				if(i < ctx.ID().size()-1) buf.append(",");
			}
			buf.append("]");
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}
//
		@Override public void exitNlosoc(EMParser.NlosocContext ctx) { 
			nlosoc(ctx, "nlosoc");
		}
		@Override public void exitNloc(EMParser.NlocContext ctx) { 
			nlosoc(ctx, "nloc");
		}
		@Override public void exitNlos(EMParser.NlosContext ctx) {
			nlosoc(ctx, "nlos");
		}
		@Override public void exitSoc(EMParser.SocContext ctx) {
			nlosoc(ctx, "soc");
		}

		@Override public void visitTerminal(TerminalNode node) { 
			setJSON(node, Quotes(node.getText()));
			setTreeText(node, node.getText());
		}
//
//
		public void binaryExpression(ParserRuleContext ctx, String methodName1){
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes(methodName1));
			buf.append(",\n");

			String operator = null;
			operator = ctx.getChild(1).getText();
			buf.append(Quotes("operator")+":"+Quotes(operator));
			buf.append(",\n");
			buf.append(Quotes("leftExp")+":"+getJSON(ctx.getChild(0)));
			buf.append(",\n");
			buf.append(Quotes("rightExp")+":"+getJSON(ctx.getChild(2)));
			
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}
//		public void callExpression(ParserRuleContext ctx, String methodName1, String methodName2){
//			java.lang.reflect.Method method1;
//			java.lang.reflect.Method method2;
//			try {
//				method1 = ctx.getClass().getMethod(methodName1);
//				method2 = ctx.getClass().getMethod(methodName2);
//				if (method1.invoke(ctx) != null){
//					StringBuilder buf = new StringBuilder();
//					buf.append("{");
//					buf.append("\n");
//					buf.append(Quotes("type")+":"+Quotes(methodName1));
//					buf.append(",\n");
//
//					String operator = null;
//					operator = ctx.getChild(1).getText();
//					buf.append(Quotes("operator")+":"+Quotes(operator));
//					buf.append(",\n");
//					buf.append(Quotes("leftExp")+":"+getJSON((ParseTree) method1.invoke(ctx)));
//					buf.append(",\n");
//					buf.append(Quotes("rightExp")+":"+getJSON((ParseTree) method2.invoke(ctx)));
//					
//					buf.append(",\n");
//					buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
//					
//					buf.append("\n}");
//					setJSON(ctx, buf.toString());
//				}else
//					setJSON(ctx, getJSON((ParseTree) method2.invoke(ctx)));
//
//			} catch (IllegalAccessException e) {
//				// TODO Auto-generated catch block
//				e.printStackTrace();
//			}
//			catch ( IllegalArgumentException  e) {
//				// TODO Auto-generated catch block
//				e.printStackTrace();
//			}
//			catch ( InvocationTargetException e) {
//				// TODO Auto-generated catch block
//				e.printStackTrace();
//			}catch (SecurityException e) { 
//				e.printStackTrace();
//			}
//			catch (NoSuchMethodException e) {
//				e.printStackTrace();
//			}
//		}
//
		public void nlosoc(ParserRuleContext ctx, String type) { 
			StringBuilder buf = new StringBuilder();
			buf.append("{");
			buf.append("\n");
			buf.append(Quotes("type")+":"+Quotes(type));
			buf.append(",\n");
			String tokenName = ctx.getText().replaceAll("\\n", "\\\\n");
			buf.append(Quotes("name")+":"+Quotes(tokenName));
			buf.append(",\n");
			buf.append(Quotes("text")+":"+Quotes(ctx.getText()));
			buf.append("\n}");
			setJSON(ctx, buf.toString());
			setTreeText(ctx, ctx.getText());
		}

		public static String Quotes(String s) {
			if ( s==null || s.charAt(0)=='"' ) return s;
			return '"'+s+'"';
		}
//
	}

	// Main Functions
	
	
	public static String InputStreamToIR(InputStream stream) {
		ANTLRInputStream input = null;
		try {
			input = new ANTLRInputStream(stream);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
		EMLexer lexer = new EMLexer( input);
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		EMParser parser = new EMParser(tokens);
		parser.setBuildParseTree(true);
		ParseTree tree = parser.emfile();
		ParseTreeWalker walker = new ParseTreeWalker();
		JSONEmitter converter = new JSONEmitter();
		walker.walk(converter, tree);	
		String result = converter.getJSON(tree);
		
		return result;

	}
	public static String StringToIR(String matlabCode) {
		try {
			InputStream stream = new ByteArrayInputStream(matlabCode.getBytes(StandardCharsets.UTF_8.name()));
			return InputStreamToIR(stream);
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return null;
	}
	
	public static void MFileToIR(String inputFilePath, String outputFilePath) {
		try {
			InputStream stream = new FileInputStream(inputFilePath);
			String result = InputStreamToIR(stream);
			try {
				PrintWriter out = new PrintWriter(outputFilePath);
				out.println(result);
				out.close();
			}catch (Exception e) {
				// TODO: handle exception
				e.printStackTrace();
			}
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
	public static void main(String[] args) throws Exception {
		String inputFile = null;
		if (args.length > 0) 
			inputFile = args[0];
		InputStream is = System.in;
		if (inputFile != null) {
			try {
				is = new FileInputStream(inputFile);
				String result = InputStreamToIR(is);
				System.out.println(result);
			}catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				System.out.println("File '"+ inputFile+"' Not Found.");
			}
		}else {
			StringBuilder buf = new StringBuilder();
			buf.append("f(x)");
			String result = StringToIR(buf.toString());
			System.out.println(result);
		}
		

	}
}
