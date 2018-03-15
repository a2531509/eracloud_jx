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
    <title>卡片档案管理</title>	
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		
		$(function() {
			 $("#psamState").combobox({
					width:174,
					valueField:'codeValue',
					editable:false,
					value:"",
				    textField:"codeName",
				    panelHeight:'auto',
				    data:[{codeValue:"",codeName:"请选择"},{codeValue:"0",codeName:"未领用"},{codeValue:"1",codeName:"已注销"},{codeValue:"2",codeName:"已领用"},]
				});
			$("#div_import").dialog({
				title : "PSAM卡批量导入",
				width : 400,
				height : 153,
				closed : true,
				modal : true,
				closable : false,
				buttons : [
					{text:"取消", iconCls:"icon-cancel", handler:function(){
						$("#div_import").dialog("close");
					}}
				],
				onClose : function(){
					$("#importFile").val("");
				}
			});
			
			$("#dialog_use").dialog({
				title : "PSAM卡批量领用",
				width : 600,
				height : 183,
				closed : true,
				modal : true,
				closable : false,
				buttons : [
					{text:"领用", iconCls:"icon-ok", handler:function(){
						batchUse();
					}},
					{text:"取消", iconCls:"icon-cancel", handler:function(){
						$("#dialog_use").dialog("close");
					}}
				],
				onClose : function(){
					$("#psamRreceive").val("");
					$("#psamRreceiveDate").val("");
				}
			});
			
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "BasePsam/basePsamAction!queryBasePsam.action",
				width : $(this).width() - 0.1,
				height : $(this).height() - 45,
				pagination:true,
				pageList:[100,500,1000,2000,5000],
				rownumbers:true,
				border:true,
				fit:true,
				singleSelect:false,
				checkOnSelect:true,
				striped:true,
				autoRowHeight:true,
				frozenColumns:[[
				                {field:"", checkbox:true},
                                {field:'PSAM_NO',title:'psam卡序列号',sortable:true,width : parseInt($(this).width() * 0.15)},
                                {field:'PSAM_ID',title:'psam卡物理卡号',sortable:true,width : parseInt($(this).width() * 0.1)},
                                {field:'PSAM_END_NO',title:'psam卡终端编号',sortable:true,width : parseInt($(this).width() * 0.1)},
                                {field:'PSAM_ISSUSE_DATE',title:'卡发行日期',sortable:true,width : parseInt($(this).width() * 0.08)},
                                {field:'PSAM_VALID_DATE',title:'卡有效日期',sortable:true,width : parseInt($(this).width() * 0.08)},
				                ]],
				columns : [ [  
								{field:'PSAM_USE',title:'卡片用途',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'PSAM_STATE',title:'卡片状态',sortable:true,width : parseInt($(this).width() * 0.05),formatter:function(value,row,index){
									if(value == "已领用"){
										return "<span style=\"color:red;\">" + value + "</span>";
									}else{
										return value;
									}
								}},
								{field:'PSAM_BRAND',title:'品牌分类',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'PSAM_MANUFACTURER',title:'生产厂家',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'OPER_DATE',title:'登记日期',sortable:true,width : parseInt($(this).width() * 0.12)},
								{field:'PROVIDER_ID',title:'供应商编号',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'OPER_ID',title:'操作人',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'NOTE',title:'备注',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'PSAM_RECEIVE',title:'领用人',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'PSAM_RECEIVE_DATE',title:'领用日期',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'RECEIVE_TIME',title:'领用操作时间',sortable:true,width : parseInt($(this).width() * 0.12)},
								{field:'RECEIVE_USERID',title:'领用操作员编号',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'CANCEL_USERID',title:'注销操作员编号',sortable:true,width : parseInt($(this).width() * 0.1)},
								{field:'CANCEL_DATE',title:'注销时间',sortable:true,width : parseInt($(this).width() * 0.12)},
								{field:'CANCEL_REASON',title:'注销原因',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'PSAM_TYPE',title:'类型',sortable:true,width : parseInt($(this).width() * 0.06),formatter:function(value,row){
					            	  if(row.PSAM_TYPE == '1'){
					            		  return '人社部';
					            	  }else if(row.PSAM_TYPE == '2'){
					            		  return '住建部';
					            	  }
					            	  }}		
				              ]],toolbar:'#tb',
				        
			});
		});
		function query(){
			var c = getformdata("searchCont");

			$dg.datagrid("load",c);			
		}
		
		//弹窗修改
		function updRowsOpenDlg() {
			var rows = $dg.datagrid('getChecked');
			if (rows.length==1) {
				parent.$.modalDialog({
					title : "编辑psam卡信息",
					width : 870,
					height : 500,					
					href : "BasePsam/basePsamAction!toEditBasePsam.action?psamNo="+rows[0].PSAM_NO,
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
		//领用
		function receiveRowsOpenDlg() {
			var rows = $dg.datagrid('getChecked');
			if (rows.length==1) {
				parent.$.modalDialog({
					title : "PSAM卡领用",
					width : 600,
					height : 180,
					resizable:true,
					href : "BasePsam/basePsamAction!toReceivePsam.action?psamNo="+rows[0].PSAM_NO,
					buttons : [ {
						text : '领用',
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
			}else if(rows.length > 1){
				$("#dialog_use").dialog("open");
			} else {
				jAlert("请选择至少一条记录", "warning");
				return;
			}
		}
		//注销
		function cancleRowsOpenDlg() {
			var rows = $dg.datagrid('getChecked');
			if (rows.length==1) {
				parent.$.modalDialog({
					title : "PSAM卡注销",
					width : 700,
					height : 220,
					resizable:true,
					href : "BasePsam/basePsamAction!toCanclePsam.action?psamNo="+rows[0].PSAM_NO,
					buttons : [ {
						text : '注销',
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
			$.modalDialog({
				title : "新增psam卡信息",
				width : 870,
				height : 500,
				resizable:true,
				href : "BasePsam/basePsamAction!toAddBasePsam.action",
				buttons : [ {
					text : '保存',
					iconCls : 'icon-ok',
					handler : function(){
						$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
						var f = $.modalDialog.handler.find("#form");
						f.submit();
					}
				}, {
					text : '取消',
					iconCls : 'icon-cancel',
					handler : function() {
						$.modalDialog.handler.dialog('destroy');
						$.modalDialog.handler = undefined;
					}
				}
				]
			});
		}
		//删除选中记录
		function delRowsOpenDlg(){
			var currow = $dg.datagrid("getSelected");
			if(currow){
				
				$.messager.confirm("系统消息","您确定要删除【" + currow.PSAM_NO + "】psam卡信息吗？",function(r){
					if(r){
						$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
						
						$.post("BasePsam/basePsamAction!deleteBasePsam.action",{psamNo:currow.PSAM_NO},function(data,status){							
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
	
		function openImprotDlg(){
			$("#div_import").dialog("open");
		}

		function importTmls(){
			var val = $("#importFile").val();
			if(!val){
				jAlert("请选择导入文件", "warning");
				return;
			}
			
			$.messager.confirm("系统消息", "确定导入选择的批量PSAM卡文件？", function(r){
				if(r){
					$.messager.progress({
						text:"数据处理中, 请稍候..."
					});
					$.ajaxFileUpload({  
			            url:"BasePsam/basePsamAction!importBatchPSAMCard.action",
			            fileElementId:['importFile'],
			            dataType:"json",
			            success: function(data, status){
			            	$.messager.progress("close");
			            	
			            	if(data.status == '1'){
			            		jAlert(data.errMsg, 'warning');
			            		return;
			            	}
			            	
			            	if(data.hasFail){
			            		$.messager.confirm("系统消息", data.msg + ", 点击【确定】导出失败记录", function(r){
			            			if(r){
			            				$("#div_import").children("iframe").attr("src", "BasePsam/basePsamAction!exportBatchPsamFailList.action?expid=" + data.expid);
			            			}
			            		});
			            	} else {
				            	$.messager.alert("系统消息", data.msg, "info", function(){
					            	$("#div_import").dialog("close");
				            	});
			            	}
			            },
			            error: function (data, status, e){
			            	$.messager.progress("close");
			            	jAlert(e, 'error');
			            }
			        });
				}
			});
		}
		
		function downloadTemplate(){
			$("#div_import").children("iframe").attr("src", "merchantRegister/merchantRegisterAction!downloadTemplate.action?template=PSAMCardBatchImportTemplate");
		}
		
		function batchUse(){
			var rows = $dg.datagrid('getSelections');
			if(!rows || rows.length < 1){
				jAlert("请选择至少一条记录", "warning");
				return;
			}
			
			var psamRreceive = $("#psamRreceive").val();
			var psamRreceiveDate = $("#psamRreceiveDate").datebox("getValue");
			if(!psamRreceive || !psamRreceiveDate){
				jAlert("领用人和领用日期不能为空", "warning");
				return;
			}
			
			var psamNos = "";
			var num = 0;
			for(var i in rows){
				num ++;
				psamNos += rows[i].PSAM_NO + ",";
			}
			
			$.messager.confirm("系统消息", "确认批量领用共【" + num + "】数量的 PSAM 卡吗?", function(r){
				if(r){
					$.messager.progress({text:"数据处理中, 请稍候....."});
					$.post("BasePsam/basePsamAction!batchUsePSAM.action", {
							"basePsam.psamRreceive":psamRreceive,
							"basePsam.psamRreceiveDate":psamRreceiveDate,
							psamNos:psamNos
						}, function(data){
							$.messager.progress("close");
							if(data.status == "0"){
								jAlert("领用成功", "info", function(){
									$("#dialog_use").dialog("close");
									query();
								});
							} else {
								jAlert("领用失败， " + data.errMsg);
							}
					}, "json");
				}
			});
		}
	</script>
	
  </head>
   <body class="easyui-layout" data-options="fit:true">
			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>PSAM卡信息</strong></span>进行相应操作!</span>
			</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
		<div id="tb" >
			<form id="searchCont">
				<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
					<tr>
						<td style="padding-left:2px">卡序列号：</td>						
						<td class="tableright"><input type="text" name="psamNo" id="psamNo" class="textinput" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
						<td style="padding-left:2px">卡片状态：</td>
						<td class="tableright">
						<select id="psamState" class="easyui-combobox easyui-validatebox" name="psamState" style="width:174px;" ></select></td>
						<td style="padding-left:2px">
						        <a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="query();">查询</a>
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"  plain="false" onclick="addRowsOpenDlg();">添加</a>
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">编辑</a>
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove"  plain="false" onclick="delRowsOpenDlg();">删除</a>
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-signin" plain="false" onclick="receiveRowsOpenDlg();">领用</a>
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-signout"  plain="false" onclick="cancleRowsOpenDlg();">注销</a>
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" plain="false" onclick="openImprotDlg()">批量导入</a>
						</td>
					</tr>
				</table>
		    </form>
		</div>
	  		<table id="dg" title="psam卡信息"></table>
	 </div>
	 <div id="div_import" style="padding: 1% 10%" class="datagrid-toolbar">
			<table width="100%" style="margin-top: 5px">
				<tr>
					<td><input name="file" type="file" id="importFile" style="border: 1px #ccc solid;" accept="application/vnd.ms-excel"></td>
					<td><a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" plain="false" onclick="importTmls()">导入</a></td>
				</tr>
			</table>
			<br>
			<a href="javascript:void(0)" onclick="downloadTemplate()">点击此处</a>下载导入模版
			<iframe style="display: none;"></iframe>
		</div>
		<div id="dialog_use" style="padding: 5% 5%" class="datagrid-toolbar">
			<table width="100%" style="margin-top: 5px" class="tablegrid">
				<tr>
					<th class="tableleft">领用人</th>
					<td class="tableright"><input name="basePsam.psamRreceive" id="psamRreceive" required="required" maxlength="50"  class="textinput easyui-validatebox"/></td>
					<th class="tableleft">领用日期</th>
					<td class="tableright"><input name="basePsam.psamRreceiveDate" id="psamRreceiveDate" class="easyui-datebox easyui-validatebox"/></td>
				</tr>
			</table>
		</div>
  </body>
</html>
