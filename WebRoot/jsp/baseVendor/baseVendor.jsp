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
    <title>卡商管理</title>	
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		
		$(function() {
			 $("#makeWay").combobox({
					width:150,
					valueField:'codeValue',
					editable:false,
					value:"",
				    textField:"codeName",
				    panelHeight:'auto',
				    data:[{codeValue:"",codeName:"请选择"},{codeValue:"0",codeName:"本地"},{codeValue:"1",codeName:"外包"}]
				});
			 $("#state").combobox({
					width:150,
					valueField:'codeValue',
					editable:false,
					value:"",
				    textField:"codeName",
				    panelHeight:'auto',
				    data:[{codeValue:"",codeName:"请选择"},{codeValue:"0",codeName:"正常"},{codeValue:"1",codeName:"注销"}]

				});
		    
			
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "baseVendor/baseVendorAction!queryBaseVendor.action",
				width : $(this).width() - 0.1,
				height : $(this).height() - 45,
				pagination:true,
				rownumbers:true,
				border:true,
				fit:true,
				singleSelect:false,
				checkOnSelect:true,
				striped:true,
				autoRowHeight:true,
				columns : [ [  
								{field:'VENDOR_ID',title:'厂商编号',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'VENDOR_NAME',title:'厂商名称',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'MAKE_WAY',title:'制卡方式',sortable:true,width : parseInt($(this).width() * 0.05)},
								{field:'ADDRESS',title:'厂商地址',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'CONTACT',title:'联系人',sortable:true,width : parseInt($(this).width() * 0.05)},	
								{field:'C_TEL_NO',title:'联系人电话',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'CEO_NAME',title:'单位负责人',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'CEO_TEL_NO',title:'品牌分类',sortable:true,width : parseInt($(this).width() * 0.05)},
								{field:'FAX_NO',title:'传真号码',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'EMAIL',title:'EMAIL',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'POST_CODE',title:'邮政编码',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'OPEN_DATE',title:'创建日期',sortable:true,width : parseInt($(this).width() * 0.07)},
								{field:'OPEN_USER_ID',title:'创建操作人',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'CLS_USER_ID',title:'注销人',sortable:true,width : parseInt($(this).width() * 0.05)},
								{field:'CLS_DATE',title:'注销日期',sortable:true,width : parseInt($(this).width() * 0.07)},
								{field:'STATE',title:'状态',sortable:true,width : parseInt($(this).width() * 0.05),formatter:function(value,row,index){
									if(value == "注销"){
										return "<span style=\"color:red;\">" + value + "</span>";
									}else{
										return value;
									}
								}}
				              ]],toolbar:'#tb',
				        
			});
		});
		function query(){
			$dg.datagrid("load",{
				"vendorName":$("#vendorName").val(),
				"makeWay":$("#makeWay").combobox("getValue"),
				"state":$("#state").combobox("getValue")
			});			
		}
		
		//弹窗修改
		function updRowsOpenDlg() {
			var rows = $dg.datagrid('getChecked');
			if (rows.length==1) {
				parent.$.modalDialog({
					title : "编辑卡片信息",
					width : 870,
					height : 500,					
					href : "baseVendor/baseVendorAction!toEditBaseVendor.action?vendorId="+rows[0].VENDOR_ID,
					buttons : [ {
						text : '编辑',
						iconCls : 'icon-ok',
						handler : function() {
							
							parent.$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
							var f = parent.$.modalDialog.handler.find("#form");							
							f.submit();
						}
					}, {
						text : '取消',
						iconCls : 'icon-cancel',
						handler : function() {
							parent.$.modalDialog.handler.dialog('destroy');
							parent.$.modalDialog.handler = undefined;
						}
					}
					]
				});
			}else{
				parent.$.messager.show({
					title :"提示",
					msg :"请选择一行记录!",
					timeout : 1000 * 2
				});
			}
		}
		//弹窗增加
		function addRowsOpenDlg() {
			var row = $dg.datagrid('getSelected');
			parent.$.modalDialog({
				title : "新增psam卡信息",
				width : 870,
				height : 500,
				resizable:true,
				href : "baseVendor/baseVendorAction!toAddBaseVendor.action",
				buttons : [ {
					text : '保存',
					iconCls : 'icon-ok',
					handler : function(){
						parent.$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
						var f = parent.$.modalDialog.handler.find("#form");
						f.submit();
					}
				}, {
					text : '取消',
					iconCls : 'icon-cancel',
					handler : function() {
						parent.$.modalDialog.handler.dialog('destroy');
						parent.$.modalDialog.handler = undefined;
					}
				}
				]
			});
		}
		//删除选中记录
		function delRowsOpenDlg(){
			var currow = $dg.datagrid("getSelected");
			if(currow){
				if(currow.STATE != "注销"){
					$.messager.alert("系统消息","【正常】状态下的卡商信息不能进行删除，请先进行注销。<br/><span style=\"color:red\">提示：只有【注销】状态下的卡商信息可以进行删除！</span>","error");
					return;
				}
				
				$.messager.confirm("系统消息","您确定要删除【" + currow.VENDOR_ID + "】卡商信息吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						
						$.post("baseVendor/baseVendorAction!deleteBaseVendor.action",{vendorId:currow.VENDOR_ID},function(data,status){							
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
	
		function cancelRowsOpenDlg(type){
			var st = "";
			if(type == "0"){
				st = "激活";
			}else if(type == "1"){
				st = "注销";
			}
			var currow = $dg.datagrid("getSelected");
			if(currow){
				if(type == "0" && currow.STATE == "正常"){
					$.messager.alert("系统消息","当前卡商已经处于【正常】状态！无需重复激活！","warning");
					return;
				}
				if(type == "1" && currow.STATE == "注销"){
					$.messager.alert("系统消息","当前卡商已经处于【注销】状态！无需重复注销！","warning");
					return;
				}			
				$.messager.confirm("系统消息","您确定要"+st+"【" + currow.VENDOR_ID + "】卡商信息吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						
						$.post("baseVendor/baseVendorAction!cancelBaseVendor.action",{vendorId:currow.VENDOR_ID,queryType:type},function(data,status){							
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
			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>卡商信息</strong></span>进行相应操作!</span>
			</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
		<div id="tb" >
			<form id="searchCont">
				<table cellpadding="0" cellspacing="0" width="100%" class="tablegrid">
					<tr>
						<td style="padding-left:2px">厂商名称：</td>						
						<td class="tableright"><input type="text" name="vendorName" id="vendorName" class="textinput"  style="width:150px"/></td>
						<td style="padding-left:2px">制卡方式：</td>
						<td class="tableright"><input type="text" name="makeWay" id="makeWay" class="textinput"  style="width:20%"/></td>
						<td style="padding-left:2px">厂商状态：</td>						
						<td class="tableright"><input type="text" name="state" id="state" class="textinput" style="width:20%"/></td>
						<td style="padding-left:2px">
						    <a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="query();">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"  plain="false" onclick="addRowsOpenDlg();">添加</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">编辑</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove"  plain="false" onclick="delRowsOpenDlg();">删除</a>
						</td>
						<td style="padding-left:2px">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-signout"  plain="false" onclick="cancelRowsOpenDlg('1');">注销</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-signin"  plain="false" onclick="cancelRowsOpenDlg('0');">激活</a>
						</td>
					</tr>
				</table>
		    </form>
		</div>
	  		<table id="dg" title="卡商信息"></table>
	 </div>	  
  </body>
</html>
