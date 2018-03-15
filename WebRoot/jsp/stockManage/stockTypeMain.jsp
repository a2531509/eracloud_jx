<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $dg;
	$(function(){
		createSysCode({id:"stkType1",codeType:"STK_TYPE"});
		createCustomSelect({
			id:"stkCode1",
			value:"stk_code",
			text:"stk_name || '【' || stk_code || '】'",
			table:"stock_type",where:"stk_code is not null ",
			orderby:"stk_code asc"
		});
		createLocalDataSelect({
			id:"stkCodeState1",
			data:[{value:"",text:"请选择"},{value:"0",text:"正常"},{value:"1",text:"注销"}]
		});
		$dg=createDataGrid({
			id:"dg",
			url:"stockManage/stockManageAction!findAllStkCode.action",
			frozenColumns:[[
				{field:"V_V",checkbox:true},
				{field:"STK_TYPE",title:"库存种类代码",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"ACC_NAME",title:"库存种类名称",sortable:true,width:parseInt($(this).width()*0.09)},
				{field:"STK_CODE",title:"库存类型代码",sortable:true,width:parseInt($(this).width()*0.077)},
				{field:"STK_NAME",title:"库存类型名称",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"LSTFLAG",title:"是否有明细",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"STKCODESTATE",title:"状态",sortable:true,width:parseInt($(this).width()*0.06),formatter:function(value,row,index){
					if(value != "正常"){
						return "<span style=\"color:red\">" + value + "<span>";
					}else{
						return value;
					}
				}},
				{field:"OUTFLAG",title:"出库方式",sortable:true,width:parseInt($(this).width()*0.08)}
			]],
			columns:[[
				{field:"ORG_NAME",title:"机构",sortable:true,width:parseInt($(this).width()*0.15)},
				{field:"OPENDATE",title:"创建日期",sortable:true,width:parseInt($(this).width()*0.12)},
				{field:"OPENUSERID",title:"创建柜员",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"CLSDATE",title:"注销日期",sortable:true,width:parseInt($(this).width()*0.12)},
				{field:"CLSUSERID",title:"注销柜员",sortable:true},
				{field:"NOTE",title:"备注",sortable:true}
			]]
		});
	});
	function query(){
		var params = getformdata("form");
		params["queryType"] = "0";
		$dg.datagrid("reload",params);
	}
	function addRowsOpenDlg(type){
		var currow = $dg.datagrid("getSelected");
		if(type == "0" || (currow && type == "1")){
			var subtitle = "",subicon = "",stkcode = "";
			if(type == "0"){
				subtitle = "新增库存类型";subicon = "icon-add";
			}else{
				subtitle = "编辑库存类型";subicon = "icon-edit";stkcode = currow.STK_CODE;
			}
			parent.$.modalDialog({
				title:subtitle,width:800,height:300,iconCls:subicon,
				href:"stockManage/stockManageAction!toStockTypeAddIndex.action?stockType.stkCode=" + stkcode + "&queryType=" + type,		
				buttons:[ 
			         {
						text:"保存",iconCls:"icon-ok",handler:function(){parent.save($dg);}
					 },
					 {
						text:"取消",iconCls:"icon-cancel",handler:function(){parent.$.modalDialog.handler.dialog("destroy");parent.$.modalDialog.handler = undefined;}
					 }
				]
			});
		}else{
			$.messager.alert("系统消息","请选择一行记录信息在进行操作！","error");
		}
	}
	function enableOrDisable(type){
		var st = "";
		if(type == "4"){st = "启用库存类型";}else if(type == "3"){st = "注销库存类型";}
		var currow = $dg.datagrid("getSelected");
		if(currow){
			if(type == "4" && currow.STK_CODE_STATE == "0"){
				$.messager.alert("系统消息","当前库存类型已经处于【正常】状态！无需重复启用！","warning");
				return;
			}
			if(type == "3" && currow.STK_CODE_STATE == "1"){
				$.messager.alert("系统消息","当前库存类型已经处于【注销】状态！无需重复注销！","warning");
				return;
			}
			$.messager.confirm("系统消息","您确定要" + st + "【" + currow.STK_NAME + "】吗？",function(r){
				if(r){
					$.messager.progress({text:"数据处理中，请稍后...."});
					$.post("stockManage/stockManageAction!saveOrUpdateStockType.action","stockType.stkCode=" + currow.STK_CODE + "&queryType=" + type,function(data,status){
						$.messager.progress("close");
						$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"), function() {
							 if(data.status == "0"){
								 $dg.datagrid("reload");
							 }
						});
					},"json");
				}
			});
		}else{
			$.messager.alert("系统消息","请选择一行记录信息在进行操作！","error");
		}
	}
	function saveDel(){
		var currow = $dg.datagrid("getSelected");
		if(currow){
			if(currow.STK_CODE_STATE != "1"){
				$.messager.alert("系统消息","【正常】状态下的库存类型不能进行删除，请先进行注销。<span style=\"color:red\">提示：只有【注销】状态下的库存类型可以进行删除！</span>","error");
				return;
			}
			$.messager.confirm("系统消息","您确定要删除库存类型【" + currow.STK_NAME + "】吗？",function(r){
				if(r){
					$.messager.progress({text:"数据处理中，请稍后...."});
					$.post("stockManage/stockManageAction!saveOrUpdateStockType.action","stockType.stkCode=" + currow.STK_CODE + "&queryType=2",function(data,status){
						$.messager.progress("close");
						$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function() {
							 if(data.status == "0"){
								 $dg.datagrid("reload");
							 }
						});
					},"json");
				}
			});
		}else{
			$.messager.alert("系统消息","请选择一行记录信息在进行操作！","error");
		}
	}
</script>
<n:initpage title="库存类型信息进行管理！">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<form id="form">
				<table style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft">库存类型种类：</td>
						<td class="tableright"><input id="stkType1" type="text" class="textinput" name="stockType.stkType"/></td>
						<td class="tableleft">库存类型代码：</td>
						<td class="tableright"><input id="stkCode1" type="text" class="textinput" name="stockType.stkCode"/></td>
						<td class="tableleft">状态：</td>
						<td class="tableright"><input id="stkCodeState1" type="text" class="textinput" name="stockType.stkCodeState"/></td>
						<td style="text-align:center;">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false"  onclick="query()">查询</a>
							<shiro:hasPermission name="stockTypeAdd">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"    plain="false"  onclick="addRowsOpenDlg('0');">添加</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="stockTypeEdit">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit"   plain="false"  onclick="addRowsOpenDlg('1');">编辑</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="stockTypeDel">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" plain="false"  onclick="saveDel();">删除</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="stockTypeDisable">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-signout" plain="false"  onclick="enableOrDisable('3');">注销</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="stockTypeEnable">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-signin"    plain="false"  onclick="enableOrDisable('4');">激活</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</form>
		</div>
	 	<table id="dg" title="库存类型信息"></table>
	</n:center>
</n:initpage>