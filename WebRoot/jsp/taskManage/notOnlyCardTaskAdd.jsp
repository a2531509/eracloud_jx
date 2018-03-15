<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript">	
	$(function() {
		createSysCode({
			id:"cardType2",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_JMK_BCP%>,<%=com.erp.util.Constants.CARD_TYPE_FJMK%>,<%=com.erp.util.Constants.CARD_TYPE_FJMK_XS%>",
			isShowDefaultOption:true
		});		
		createCustomSelect({
			id:"regionId2",
			value:"region_id",
			text:"region_name || '【' || region_code || '】'",
			table:"base_region",
			where:"region_id not in ('330412','330405','330402','330411')",
			orderby:"region_code asc",
			missingMessage:"请选择采购区域信息<br/><span style='color:red'>注意：默认情况下将同等数量采购所有区域</span>",
			invalidMessage:"请选择采购区域信息<br/><span style='color:red'>注意：默认情况下将同等数量采购所有区域</span>",
			required:true,
			validType:"email"
		});
		
		createCustomSelect({
			id:"bankId",
			value:"bank_id",
			text:"bank_name",
			table:"base_bank",
			where:"bank_state = '0'",
			orderby:"bank_id asc",
			from:1,
			to:20
		});
		
		$("#taskSum").textbox({    
		    required:true,
		    type:"text",
		    missingMessage:"请输入采购数量",
		    invalidMessage:"请输入采购数量"
		});
		$("#taskSum").textbox("textbox").bind("keydown",function(){
			var value_ = $("#taskSum").textbox("getText");
			var _reg = /^[1-9]+[0-9]*$/g
			if(!_reg.test(value_)){
				$("#taskSum").textbox("setText",value_.replace(/\D/g,""));
			}
		});
		$("#taskSum").textbox("textbox").bind("keyup",function(){
			var value_ = $("#taskSum").textbox("getText");
			var _reg = /^[1-9]+[0-9]*$/g
			if(!_reg.test(value_)){
				$("#taskSum").textbox("setText",value_.replace(/\D/g,""));
			}
		});
	});
	function saveCg(oldGrid){
		if($("#cardType2").combobox("getValue") == "" || $("#cardType2").combobox("getValue") == "erp2_erp2"){
			$.messager.alert("系统消息","请选择采购的卡类型！","error",function(){
                $("#cardType2").combobox("showPanel")
            });
			return;
		}
		
		var taskNum = $("#taskSum").combobox("getText");
		if(taskNum == ""){
			$.messager.alert("系统消息","请输入的采购数量！","error",function(){
				$("#taskSum").textbox("textbox").focus(); 
			});
			return;
		}
		var _reg = /^[1-9]+[0-9]*$/g
		if(!_reg.test(taskNum)){
			$.messager.alert("系统消息","输入的采购数量不正确！","error");
			return;
		}
		if($("#bankId").combobox("getValue") == "" ){
			$.messager.alert("系统消息","请选择銀行！","error",function(){
                $("#bankId").combobox("showPanel")
            });
			return;
		}
		if($("#regionId2").combobox("getValue") == "erp2_erp2"){
			$.messager.alert("系统消息","请选择采购的区域！","error");
			return;
		}
		var tip = "";
		if($("#regionId2").combobox("getValue") == ""){
			tip = "注意：采购区域为空，默认将同等数量采购所有的区域？";
			$.messager.confirm("系统消息",tip,function(r){
				if(r){
					$.messager.confirm("系统消息","您确定要进行生成非个性化采购任务吗？",function(r){
						if(r){
							$.messager.progress({text:"正在生成采购任务信息，请稍候..."});
							$.ajax({
								url:"taskManagement/taskManagementAction!saveFgxhCg.action",
								data:$("#addView").serialize(),
								dataType:"json",
								success:function(rsp){
									if(rsp["status"] == "0"){
										$.messager.alert("系统消息","采购任务生成成功！","info",function(){
											oldGrid.datagrid("reload");
											parent.$.modalDialog.handler.dialog("destroy");
											parent.$.modalDialog.handler = undefined;
										});
									}else{
										$.messager.alert("系统消息",rsp["errMsg"],"error");
									}
								},
								complete:function(xhq,textStatus){
									$.messager.progress("close");
								},error:function(XMLHttpRequest,textStatus,errorThrown){
									
								}
							});
						}
					});
				}
			});
		}else{
			$.messager.confirm("系统消息","您确定要进行生成非个性化采购任务吗？",function(r){
				if(r){
					$.messager.progress({text:"正在生成采购任务信息，请稍候..."});
					$.ajax({
						url:"taskManagement/taskManagementAction!saveFgxhCg.action",
						data:$("#addView").serialize(),
						dataType:"json",
						success:function(rsp){
							if(rsp["status"] == "0"){
								$.messager.alert("系统消息","采购任务生成成功！","info",function(){
									oldGrid.datagrid("reload");
									parent.$.modalDialog.handler.dialog("destroy");
									parent.$.modalDialog.handler = undefined;
								});
							}else{
								$.messager.alert("系统消息",rsp["errMsg"],"error");
							}
						},
						complete:function(xhq,textStatus){
							$.messager.progress("close");
						},error:function(XMLHttpRequest,textStatus,errorThrown){
							
						}
					});
				}
			});
		}
	}
</script>
<n:layout>
	<n:center layoutOptions="border:false">
		<form id="addView" method="post" style="width:100%;height:100%;">
			<table style="width:100%;" class="datagrid-toolbar">
				<tr>
					<td class="tableleft">卡类型：</td>
					<td class="tableright"><input id="cardType2" name="task.cardType" type="text" class="textinput"/></td>
					<td class="tableleft">区域：</td>
					<td class="tableright"><input id="regionId2" name="task.regionId" type="text" class="textinput"/></td>
					<td class="tableleft">数量：</td>
					<td class="tableright"><input id="taskSum" name="task.taskSum" type="text" class="textinput"/></td>
				</tr>
				
				<tr>
					<th class="tableleft">银行名称：</th>
					<td class="tableright"><input id="bankId" name="task.bankId" type="text" class="textinput easyui-validatebox" /></td>
				</tr>
				
			</table>
		</form>
    </n:center>
</n:layout>