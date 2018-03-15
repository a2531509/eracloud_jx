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
    <title>积分参数管理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript"> 
		var $dg;
		var $grid;
		$(function(){
			$("#dealCode").combobox({
				url:"/pointManage/pointManageAction!findAllDealCode.action",
				width:174,
				valueField:"DEAL_CODE",
				editable:false,
			    textField:"DEAL_CODE_NAME"
			});
			$("#pointType").combobox({
				width:174,
				valueField:"codeValue",
				editable:false,
			    textField:"codeName",
			    panelHeight:"auto",
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:'1',codeName:"固定积分"},{codeValue:'2',codeName:"比例积分"}]
			});
			
			$("#pointState").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:'0',codeName:"正常"},{codeValue:'1',codeName:"注销"}]
			}); 
			
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url:"/pointManage/pointManageAction!pointParaQuery.action",
				fit:true,
				pagination:true,
				rownumbers:true,
				border:false,
				striped:true,
				singleSelect:false,
				autoRowHeight:true,
				showFooter: true,
				fitColumns:true,
				scrollbarSize:0,
				pageSize:20,
				columns:[[
					{field:'V_V',checkbox:true},
					{field:'ID',title:'积分参数编号',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'DEAL_CODE_NAME',title:'交易代码',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'POINT_TYPE',title:'积分类型',sortable:true,width:parseInt($(this).width()*0.1),formatter:function(value,row,index){
						if(value == "1"){
							return "固定积分";
						}else{
							return "比例积分";
						}
					}},
					{field:'POINT_GD_VALUE',title:'固定积分值',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'POINT_BL_VALUE',title:'比例积分比例',sortable:true,width:parseInt($(this).width()*0.1),formatter:function(value,row,index){
						if(value !=""){
							return value+"‱";
						}
					}},
					{field:'POINT_MAX_VALUE',title:'最大积分值',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'STATE',title:'积分状态',sortable:true,width:parseInt($(this).width()*0.1),formatter:function(value,row,index){
						if(value == "1"){
							return "<span style=\"color:red;\">" + "注销" + "</span>";
						}else{
							return "正常";
						}
					}},
					{field:'USER_ID',title:'录入柜员',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'INSERT_DATE',title:'录入时间',sortable:true,width:parseInt($(this).width()*0.1)}
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
				dealCode:$("#dealCode").combobox('getValue'),
				pointType:$("#pointType").combobox('getValue'),
				pointState:$("#pointState").combobox('getValue')
			});
		}
		/**
		*@param type 0 新增  1编辑
		*/
		function addRowsOpenDlg(type){
			var currow = $dg.datagrid("getChecked");
			if(type == "0" || (currow.length==1 && type == "1")){
				var subtitle = "";
				var subicon = "";
				var pointId = "";
				if(type == "0"){
					subtitle = "新增账户类型";
					subicon = "icon-add";
				}else{
					subtitle = "编辑账户类型";
					subicon = "icon-edit";
					pointId = currow[0].ID;
				}
				
				parent.$.modalDialog({
					title:subtitle,
					width:800,
					height:300,
					iconCls:subicon,
					href:"/pointManage/pointManageAction!pointParaEdit.action?pointId="+pointId+"&queryType="+type,		
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
				st = "启用积分参数";
			}else if(type == "1"){
				st = "禁用积分参数";
			}
			var currow = $dg.datagrid("getChecked");
			if(currow){
				var checkeIds =  "";
				for(var i=0;i<currow.length;i++){
					checkeIds = checkeIds+currow[i].ID+"|";
				}
				if(type == "0" && currow.ACC_KIND_STATE == "正常"){
					$.messager.alert("系统消息","当前积分参数已经处于【正常】状态！无需重复启用！","warning");
					return;
				}
				if(type == "1" && currow.ACC_KIND_STATE == "注销"){
					$.messager.alert("系统消息","当前积分参数已经处于【注销】状态！无需重复禁用！","warning");
					return;
				}
				$.messager.confirm("系统消息","您确定要" + st + "【" + checkeIds + "】吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						$.post("/pointManage/pointManageAction!enableOrDisablePointPara.action","checkeIds=" + checkeIds + "&queryType=" + type,function(data,status){
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
				$.messager.alert("系统消息","请选择记录信息再进行操作！","error");
			}
		}
		
		function saveDel(){
			var currow = $dg.datagrid("getChecked");
			if(currow){
				var checkeIds =  "";
				for(var i=0;i<currow.length;i++){
					checkeIds = checkeIds+currow[i].ID+"|";
				}
				$.messager.confirm("系统消息","您确定要删除积分参数编号为【" + checkeIds + "】的积分参数吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						$.post("/pointManage/pointManageAction!deletePointPara.action","checkeIds=" + checkeIds,function(data,status){
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
				$.messager.alert("系统消息","请选择记录信息再进行操作！","error");
			}
		}
		
		
	</script>
  </head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar">
			<span class="badge">提示</span>
			<span>在此你可以对<span class="label-info"><strong>系统积分按照交易类型</strong></span>进行配置！</span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="border-left:none;border-bottom:none;height:auto;overflow:hidden;">
		<div id="tb" style="padding:2px 0">
			<table class="tablegrid" cellpadding="0" cellspacing="0">
				<tr>
					<td class="tableleft">交易代码：</td>
					<td class="tableright"><input id="dealCode" type="text" class="easyui-combobox  easyui-validatebox" name="dealCode"  style="width:174px;"/></td>
					<td class="tableleft">积分类型：</td>
					<td class="tableright"><input id="pointType" type="text" class="textinput" name="pointType"  style="width:174px;"/></td>
					<td class="tableleft">状态：</td>
					<td class="tableright"><input name="pointState"  class="easyui-combobox" id="pointState" value="" type="text" data-options="panelHeight:'auto',valueField:'label',textField:'value',data:[{label:'',value:'请选择'},{label:'0',value:'在用'},{label:'1',value:'注销'}]"/></td>
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
  		<table id="dg" title="积分参数管理"></table>
	</div>
</body>
</html>