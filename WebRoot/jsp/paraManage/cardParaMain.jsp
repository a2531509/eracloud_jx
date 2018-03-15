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
    <title>卡参数管理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
			var $dg;
			var $temp;
			var $grid;
			$(function() {
				$("#card_type").combobox({
					valueField:"value",
					textField:"text",
					panelHeight:"auto",
					data:[
						{value:"", text:"请选择"},
						{value:"100", text:"全功能卡"},
						{value:"120", text:"金融市民卡"},
						{value:"210", text:"手机副卡"},
						{value:"390", text:"半成品卡"}
					],
					editable:false
				});
				
				 $dg = $("#dg");
				 $grid=$dg.datagrid({
					url : "cardParaManage/cardConfigAction!findCardParaInfo.action",
					pagination:true,
					rownumbers:true,
					border:true,
					//fitColumns: true,
					fit:true,
					scrollbarSize:0,
					striped:true,
					singleSelect:true,
					frozenColumns:[[
									{field : 'CARD_TYPE',title : '卡类型',width : parseInt($(this).width()*0.07),sortable:true,align: 'left',formatter:function(value,row){
										if("100"==row.CARD_TYPE){
											return "全功能卡";
										}else if("210"==row.CARD_TYPE){
											return "手机副卡";
										}else if("390"==row.CARD_TYPE){
											return "半成品卡";
										}else if("120"==row.CARD_TYPE){
											return "金融市民卡";
										}else{
											return "其他【" + value + "】";
										}
									}},
									{field : 'ONLY',title : '唯一持有',width : parseInt($(this).width()*0.07),sortable:true,align: 'left',formatter:function(value,row){
										if("0"==row.ONLY){
											return "是";
										}else if("1"==row.ONLY){
											return "否";
										}else{
											return "未设置";
										}
									}},
									{field : 'NAMED_FLAG',title : '记名设置',width : parseInt($(this).width()*0.07),sortable:true,formatter:function(value,row){
										//证件类型：1-身份证2-户口簿3-军官证4-护照 5-户籍证明 6-其他
										if("0"==row.NAMED_FLAG){
											return "记名";
										}else if("1"==row.NAMED_FLAG){
											return "不记名";
										}else{
											return "未设置";
										}
									}},
									{field : 'FACE_PERSONAL',title : '卡片是否个性化',width : parseInt($(this).width()*0.07),sortable:true,formatter:function(value,row){
										if("0"==row.FACE_PERSONAL){
											return "是";
										}else if("1"==row.FACE_PERSONAL){
											return "否";
										}else{
											return "未设置";
										}
									}},
									//押金（服务费）扣取方式(0日1周2月3季4半年5年)
									{field : 'IN_PERSONAL',title : '卡内是否写入个性话信息',width : parseInt($(this).width()*0.11),sortable:true,align:'left',formatter:function(value,row){
										if("0"==row.IN_PERSONAL){
											return "是";
										}else if("1"==row.IN_PERSONAL){
											return "否";
										}else{
											return "未设置";
										}
									}},
									{field : 'LSS_FLAG',title : '是否准许挂失',width : parseInt($(this).width()*0.07),sortable:true,formatter:function(value,row){
										if("0"==row.LSS_FLAG){
											return "是";
										}else if("1"==row.LSS_FLAG){
											return "否";
										}else{
											return "未设置";
										}
									}},
									{field : 'REISSUE_FLAG',title : '是否允许补卡',width : parseInt($(this).width()*0.07),sortable:true,align:'left',formatter:function(value,row){
										if("0"==row.REISSUE_FLAG){
											return "是";
										}else if("1"==row.REISSUE_FLAG){
											return "否";
										}else{
											return "未设置";
										}
									}},
									{field : 'RE_CARDNO_FLAG',title : '补卡卡号是否变化',width : parseInt($(this).width()*0.07),sortable:true,align:'left',formatter:function(value,row){
										if("0"==row.RE_CARDNO_FLAG){
											return "是";
										}else if("1"==row.RE_CARDNO_FLAG){
											return "否";
										}else{
											return "未设置";
										}
									}},
					                
					                
					                ]],
					columns : [ [ 
					              {field : 'CHG_FLAG',title : '是否允许换卡',width : parseInt($(this).width()*0.08),sortable:true,formatter:function(value,row){
										if("0"==row.CHG_FLAG){
											return "是";
										}else if("1"==row.CHG_FLAG){
											return "否";
										}else{
											return "未设置";
										}
									}},
					              {field : 'CHG_CARDNO_FLAG',title : '换卡卡号是否变化',width : parseInt($(this).width()*0.08),sortable:true,align:'left',formatter:function(value,row){
					            	  if("0"==row.CHG_CARDNO_FLAG){
					            		  return "是";
					            	  }else if("1"==row.CHG_CARDNO_FLAG){
										  return "否";
									  }else{
					            		  return "未设置";
					            	  }
					              }},
					              {field : 'STRUCT_MAIN_TYPE',title : '卡规划主类型',width : parseInt($(this).width()*0.08),sortable:true},
					              {field : 'STRUCT_CHILD_TYPE',title : '卡规划子类型',width : parseInt($(this).width()*0.08),sortable:true},
					              {field : 'CARD_VALIDITY_PERIOD',title : '有效期年数',width : parseInt($(this).width()*0.08),sortable:true,align:'left'},
					              {field : 'WALLET_CASE_RECHG_LMT',title : '钱包充值限额（分）',width : parseInt($(this).width()*0.11),sortable:true,align:'left'},
					              {field : 'ACC_CASE_RECHG_LMT',title : '账户充值限额（分）',width : parseInt($(this).width()*0.11),sortable:true,align:'left'},
					              {field : 'BANK_RECHG_LMT',title : '银行单次圈存限额（分）',width : parseInt($(this).width()*0.11),sortable:true,align:'left'},
					              {field : 'CASH_RECHG_LOW',title : '现金充值最低限额（分）',width : parseInt($(this).width()*0.11),sortable:true,align:'left'},
					              {field : 'CARD_TYPE_STATE',title : '状态',width : parseInt($(this).width()*0.03),sortable:true,formatter:function(value,row){
					            	  if("0"==row.CARD_TYPE_STATE){
					            		  return "正常";
					            	  }else if("1"==row.CARD_TYPE_STATE){
										  return "注销";
									  }else{
					            		  return "未设置";
					            	  }
					              }}
					              ] ],toolbar:'#tb',
					              onLoadSuccess:function(data){
					            	  $("input[type='checkbox']").each(function(){ if(this.checked){ this.checked=false; } });//初始话默认不选中
					            	  if(data.status != 0){
					            		 $.messager.alert('系统消息',data.errMsg,'error');
					            	  }
					              }
				});
			});
			
			function query(){
				$dg.datagrid('load',{
					queryType:'0',//查询类型
					card_type:$("#card_type").combobox("getValue")
				});
			}		
			
			//弹窗修改
			function updRowsOpenDlg() {
				var row = $dg.datagrid('getSelected');
				if (row) {
					$.modalDialog({
						title : "编辑卡参数信息",
						iconCls:"icon-edit",
						fit:true,
						maximized:true,
						shadow:false,
						//inline:true,
						closable:false,
						maximizable:false,
						href : "cardParaManage/cardConfigAction!toViewCardConfig.action?selectCartType="+row.CARD_TYPE,
						buttons : [ {
							text : '编辑',
							iconCls : 'icon-ok',
							handler : function() {
								$.modalDialog.openner= $grid;
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
				$.modalDialog({
					title : "添加卡参数信息",
					iconCls:"icon-adds",
					fit:true,
					maximized:true,
					shadow:false,
					//inline:true,
					closable:false,
					maximizable:false,
					href : "jsp/paraManage/cardParaEditDlg.jsp",
					onLoad:function(){
						var f = parent.$.modalDialog.handler.find("#form");
						f.form("load",{editOrAddFlag:1});
					},
					buttons : [ {
						text : '保存',
						iconCls : 'icon-ok',
						handler : function() {
							$.modalDialog.openner= $grid;
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
		</script>
  </head>
  <body>
  <div class="easyui-layout" data-options="fit:true">
	  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
				<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
					<span class="badge">提示</span>
					<span>在此你可以对<span class="label-info"><strong>科目信息</strong></span>进行相应操作!</span>
				</div>
		</div>
		<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
				<div id="tb" style="padding:2px 0">
					<table cellpadding="0" cellspacing="0">
						<tr>
							<td style="padding-left:2px">卡类型：</td>
							<td style="padding-left:2px"><input id="card_type" type="text" class="easyui-validatebox" name="card_type"  style="width:174px;cursor:pointer;"/></td>
							<td style="padding-left:2px">
								<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							</td>
							<td style="padding-left:2px">
								<shiro:hasPermission name="accItemEdit">
									<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add" plain="false" onclick="addRowsOpenDlg();">新增</a>
								</shiro:hasPermission>
								<shiro:hasPermission name="accItemEdit">
									<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">编辑</a>
								</shiro:hasPermission>
							</td>
						</tr>
					</table>
				</div>
		  		<table id="dg" title="卡参数信息"></table>
		  </div>
	</div>
  </body>
</html>
