<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>账户类型管理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript"> 
	//$.fn.datagrid.defaults.loadMsg = '正在处理，请稍待。。。';
		var $dg;
		var $grid;
		$(function() {
			createSysCode({
				id:"accKind",
				codeType:"ACC_KIND"
			});
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url:"accountManager/accountManagerAction!accTypeQuery.action",
				fit:true,
				pagination:true,
				rownumbers:true,
				border:false,
				striped:true,
				singleSelect:true,
				autoRowHeight:true,
				showFooter: true,
				fitColumns:true,
				scrollbarSize:0,
				pageSize:20,
				columns:[[
					{field:'V_V',checkbox:true},
					{field:'ACC_KIND',title:'账户类型编码',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'ACC_NAME',title:'账户类型名称',sortable:true,width:parseInt($(this).width()*0.09)},
					{field:'ACC_KIND_STATE',title:'账户类型状态',sortable:true,width:parseInt($(this).width()*0.077),formatter:function(value,row,index){
						if(value == "注销"){
							return "<span style=\"color:red;\">" + value + "</span>";
						}else{
							return value;
						}
					}},
					{field:'OPEN_USER_ID',title:'注册柜员',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'OPEN_DATE',title:'注册时间',sortable:true,width:parseInt($(this).width()*0.12)},
					{field:'STOP_USER_ID',title:'注销柜员',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'STOP_DATE',title:'注销时间',sortable:true,width:parseInt($(this).width()*0.12)},
					{field:'ALONE_ACTIVATE_FLAG',title:'是否需要单独激活',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'ORD_NO',title:'排序序号',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'NOTE',title:'备注',sortable:true,width:parseInt($(this).width()*0.08)}
				]],
				toolbar:'#tb',
	            onLoadSuccess:function(data){
	              if(data.status != 0){
	            		 $.messager.alert('系统消息',data.errMsg,'error');
	            	  }
	            }
			});
		});
		function query(){
			$dg.datagrid('load',{
				queryType:'0',//查询类型
				accKindState:$("#accKindState").combobox('getValue'),
				accKind:$("#accKind").combobox('getValue'),
				accKindName:$("#accKindName").val()
			});
		}
		/**
		*@param type 0 新增  1编辑
		*/
		function addRowsOpenDlg(type){
			var currow = $dg.datagrid("getSelected");
			if(type == "0" || (currow && type == "1")){
				var subtitle = "";
				var subicon = "";
				var accKind = "";
				if(type == "0"){
					subtitle = "新增账户类型";
					subicon = "icon-add";
				}else{
					subtitle = "编辑账户类型";
					subicon = "icon-edit";
					accKind = currow.ACC_KIND;
				}
				parent.$.modalDialog({
					title:subtitle,
					width:800,
					height:300,
					iconCls:subicon,
					href:"accountManager/accountManagerAction!accTypeEdit.action?accKind=" + accKind + "&queryType=" + type,		
					buttons:[ 
				        {
							text:'保存',
							iconCls:'icon-ok',
							handler:function(){
								parent.save($grid);
							}
						 },{
							text:'取消',
							iconCls:'icon-cancel',
							handler:function(){
								parent.$.modalDialog.handler.dialog('destroy');
								parent.$.modalDialog.handler = undefined;
							}
						}
					]
				});
			}else{
				$.messager.alert("系统消息","请选择一行记录信息在进行操作！","error");
			}
		}
		function enableOrDisable(type){
			var st = "";
			if(type == "0"){
				st = "启用账户类型";
			}else if(type == "1"){
				st = "禁用账户类型";
			}
			var currow = $dg.datagrid("getSelected");
			if(currow){
				if(type == "0" && currow.ACC_KIND_STATE == "在用"){
					$.messager.alert("系统消息","当前账户类型已经处于【在用】状态！无需重复启用！","warning");
					return;
				}
				if(type == "1" && currow.ACC_KIND_STATE == "注销"){
					$.messager.alert("系统消息","当前账户类型已经处于【注销】状态！无需重复禁用！","warning");
					return;
				}
				$.messager.confirm("系统消息","您确定要" + st + "【" + currow.ACC_NAME + "】吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						$.post("accountManager/accountManagerAction!enableOrDisableAccKind.action","accKind=" + currow.ACC_KIND + "&queryType=" + type,function(data,status){
							$.messager.progress('close');
							$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"), function() {
								 if(data.status == "0"){
									 $dg.datagrid("reload");
								 }
							})
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
				if(currow.ACC_KIND_STATE != "注销"){
					$.messager.alert("系统消息","【在用】状态下的账户类型不能进行删除，请先进行注销。<br/><span style=\"color:red\">提示：只有【注销】状态下的账户类型可以进行删除！</span>","error");
					return;
				}
				$.messager.confirm("系统消息","您确定要删除账户类型【" + currow.ACC_NAME + "】吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						$.post("accountManager/accountManagerAction!deleteAccKind.action","accKind=" + currow.ACC_KIND,function(data,status){
							$.messager.progress('close');
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
  </head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span>
			<span>在此你可以对<span class="label-info"><strong>账户类型信息</strong></span>进行管理！</span>
			<!-- <span style="float:right"><a href="javascript:void(0)" onclick="odefaultwindow('账户类型操作日志','/jsp/accManage/accmanagelog.jsp')">日志</a></span> -->
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<div id="tb" style="padding:2px 0">
			<table class="tablegrid" cellpadding="0" cellspacing="0">
				<tr>
					<td class="tableleft">账户类型编码：</td>
					<td class="tableright"><input id="accKind" type="text" class="easyui-combobox  easyui-validatebox" name="accKind"  style="width:174px;"/></td>
					<td class="tableleft">账户类型名称：</td>
					<td class="tableright"><input id="accKindName" type="text" class="textinput" name="accKindName"  style="width:174px;"/></td>
					<td class="tableleft">状态：</td>
					<td class="tableright"><input name="accKindState"  class="easyui-combobox" id="accKindState" value="" type="text" data-options="panelHeight:'auto',valueField:'label',textField:'value',data:[{label:'',value:'请选择'},{label:'0',value:'在用'},{label:'1',value:'注销'}]"/></td>
					<td class="tableright">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false"  onclick="query()">查询</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"    plain="false"  onclick="addRowsOpenDlg('0');">添加</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit"   plain="false"  onclick="addRowsOpenDlg('1');">编辑</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" plain="false"  onclick="saveDel();">删除</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-signout" plain="false"  onclick="enableOrDisable('1');">注销</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-signin"    plain="false"  onclick="enableOrDisable('0');">激活</a>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="账户类型管理"></table>
	</div>
</body>
</html>