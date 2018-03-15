<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<%@ include file="/layout/initpage.jsp" %>
<%-- 
#*---------------------------------------------#
# Template for a JSP
# @version: 1.2
# @author: yangn
# @author: Jed Anderson
# @describle:功能说明： 柜员交接
#---------------------------------------------#
--%>
<style>
	.messager-body div{
		word-break:break-all;
	}
</style>
<script type="text/javascript">
	var $stkCode;
	$(function(){
		if("${defaultErrorMsg}" != ""){
			$.messager.alert("系统消息","${defaultErrorMsg}","error",function(){
				window.history.go(0);
			});
			return;
		}
		
		$stkCode = $.createCustomSelect({
			id:"stkCode",
			value:"stk_code",
			text:"stk_name || '【' || stk_code || '】'",
			table:"stock_type",
			where:"stk_code is not null and stk_code_state = '0' and stk_code <> '1390' ",
			isShowDefaultOption:false,
			orderby:"stk_code asc",
			from:1,
			to:30,
			defaultValue:"1100",
			onSelect:function(option){
			}
		});
		createSysBranch("inBrchId","inUserId",{isJudgePermission:false});
		createSysBranch("brchId","userId",{isReadOnly:true},{isReadOnly:true});//,{readonly:true},{readonly:true,width:174,hasDownArrow:true}
		//addNumberValidById("startNo");
		//addNumberValidById("endNo");
		//addNumberValidById("goodsNums");
		
		$("#dg").datagrid({
			toolbar:$("#tb"),
			fit:true,
			rownumbers:true,
			url:"stockManage/stockManageAction!toStockAccQueryIndex.action?stockAcc.id.userId=${userId}&queryType=0",
			frozenColumns:[[
				{field:"ORG_NAME",title:"所属机构",sortable:true,width:parseInt($(this).width()*0.15)},
				{field:"BRCHNAME",title:"所属网点",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"USERNAME",title:"所属柜员",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"STK_CODE",title:"库存代码",sortable:true,width:parseInt($(this).width()*0.05)},
				{field:"STK_NAME",title:"库存种类",sortable:true,width:parseInt($(this).width()*0.08)}
			]],
			columns:[[
				{field:"ACC_NAME",title:"账户名称",sortable:true,width:parseInt($(this).width()*0.16)},
				{field:"ACCSTATE",title:"账户状态",sortable:true,width:parseInt($(this).width()*0.05)},
	        	{field:"GOODSSTATE",title:"物品状态",sortable:true,width:parseInt($(this).width()*0.12)},
	        	{field:"TOTNUM",title:"总数量",sortable:true,width:parseInt($(this).width()*0.05)},
	        	{field:"TOTFACEVAL",title:"总面额",sortable:true,width:parseInt($(this).width()*0.05)},
	        	{field:"AUTHUSERID",title:"开户柜员",sortable:true,width:parseInt($(this).width()*0.06)},
	        	{field:"OPENDATE",title:"开户时间",sortable:true,width:parseInt($(this).width()*0.12)},
	        	{field:"CLSUSERID",title:"注销柜员",sortable:true,width:parseInt($(this).width()*0.06)},
	        	{field:"CLSDATE",title:"注销日期",sortable:true,width:parseInt($(this).width()*0.12)},
	        	{field:"LASTDEALDATE",title:"最后交易时间",sortable:true,width:parseInt($(this).width()*0.12)},
	        	{field:"NOTE",title:"备注",sortable:true}
	        ]],
	        onLoadSuccess:function(data){
	        	if(!data || data.status == 1){
	        		jAlert(data.errMsg?data.errMsg:"没有数据", "warning");e
	        	}
	        }
		});
	});
	function tosavestockdelivery(){
		var delieryway = "2";
		if($("#stkCode").combobox("getValue") == ""){
			$.messager.alert("系统消息","将选择交接的库存类型！","error",function(){
				$("#stkCode").combobox("showPanel");
			});
			return;
		}
		if($("#inBrchId").combotree("getValue") == ""){
			$.messager.alert("系统消息","请选择交接网点！","error",function(){
				$("#inBrchId").combotree("showPanel");
			});
			return;
		}
		if($("#inUserId").combobox("getValue") == "" || $("#inUserId").combobox("getValue") == "erp2_erp2"){
			$.messager.alert("系统消息","请选择交接柜员！","error",function(){
				$("#inUserId").combobox("showPanel");
			});
			return;
		}
		if($("#brchId").combotree("getValue") == ""){
			$.messager.alert("系统消息","请选择付方网点！","error",function(){
				$("#brchId").combotree("showPanel");
			});
			return;
		}
		if($("#userId").combobox("getValue") == "" || $("#userId").combobox("getValue") == "erp2_erp2"){
			$.messager.alert("系统消息","请选择付方柜员！","error",function(){
				$("#userId").combobox("showPanel");
			});
			return;
		}
		if(dealNull($("#pwd").val()) == ""){
			$.messager.alert("系统消息","请输入交接柜员密码！","error",function(){
				$("#pwd").focus();
			});
			return;
		}
		if($("#inBrchId").combotree("getValue") == $("#brchId").combotree("getValue") && $("#inUserId").combobox("getValue") == $("#userId").combobox("getValue")){
			$.messager.alert("系统消息","交接柜员和付方柜员不能相同！","error",function(){
				
			});
			return;
		}
		$.messager.confirm("系统消息","您确认要对" + $("#inBrchId").combotree("getText") + $("#inUserId").combobox("getText") + "进行交接吗？",function(r){
			if(r){
				$.messager.progress({text : '正在进行交接，请稍后....'});
				var formdata = getformdata("tellerReceive");
				$.post("stockManage/stockManageAction!saveTellerTransitionAll.action",formdata,function(data,status){
					$.messager.progress('close');
					if(status == "success"){
						$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
							if(data.status == "0"){
								
							}else{
								
							}
						 });
					}else{
						$.messager.alert("系统消息","柜员交接出现错误，请重试！","error");
					}
				},"json");
			}
		});
	}
</script>
<n:initpage title="柜员进行库存交接操作！">
	<n:center cssClass="datagrid-toolbar">
		<div id="tb" style="padding:2px 0,width:100%">
			<form id="tellerReceive">
				<table class="tablegrid" style="width:100%">
					<tr>
						<td class="tableleft" style="width:18%;">交接网点：</td>
						<td class="tableright" colspan="3">
							<input name="rec.brchId" class="textinput" id="brchId" type="text" value="${brchId}" readonly="readonly"/>
							<label for="userId" style="margin-left:10px;">交接柜员：</label>
							<input name="rec.userId" class="textinput" id="userId" type="text" value="${userId}"/>
						</td>
					</tr>
					<tr>
						<td class="tableleft">库存代码：</td>
						<td class="tableright" colspan="3">
							<input id="stkCode" name="rec.stkCode" class="textinput" type="text"/>
						</td>
					</tr>
					<tr>
						<td class="tableleft">收方网点：</td>
						<td class="tableright" colspan="3">
							<input name="rec.inBrchId"  class="textinput" id="inBrchId" type="text"/>
							<label for="otherUserId" style="margin-left:10px;">收方柜员：</label>
							<input name="rec.inUserId"  class="textinput" id="inUserId" type="text"/>
						</td>
					</tr>
					<tr>
						<td class="tableleft"><label for="pwd" style="margin-left:10px;">收方密码：</label></td>
						<td class="tableright" colspan="3"><input type="password" name="pwd" id="pwd" class="textinput" maxlength="6"></td>
					</tr>
					<tr>
						<td colspan="1">&nbsp;</td>
					    <td class="tableright" colspan="3"><a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="tosavestockdelivery();">确认交接</a></td>
					</tr>
				</table>
			</form>
		</div>
		<table id="dg" title="【${userId}】柜员库存信息">
		</table>
	</n:center>
</n:initpage>