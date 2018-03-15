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
    <title>商户消费费率设置</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		var $querycerttype;
		$(function() {
			
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "/merchantRate/merchantRateAction!queryMerRateInfo.action",
				pagination:true,
				rownumbers:true,
				border:false,
				fit:true,
				singleSelect:false,
				checkOnSelect:true,
				striped:true,
				//fitColumns: true,
				scrollbarSize:0,
				autoRowHeight:true,
				frozenColumns:[[
								{field:'RATEID',title:'id',sortable:true,checkbox:'ture'},
								{field:'MERCHANT_ID',title:'商户编号',sortable:true,width : parseInt($(this).width() * 0.1)},
								{field:'MERCHANT_NAME',title:'商户名称',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'TR_CODE',title:'交易代码',sortable:true,width : parseInt($(this).width() * 0.12)},
								{field:'FEE_TYPE',title:'费率类型',sortable:true,width : parseInt($(this).width() * 0.05),formatter:function(value,row){
									  if(row.FEE_TYPE == '1'){
										  return '笔数费率';
									  }else{
										  return '金额费率';
									  }
								  }},
								{field:'HAVE_SECTION',title:'是否分段',sortable:true,width : parseInt($(this).width() * 0.05),formatter:function(value,row){
									  if(row.HAVE_SECTION == '0'){
										  return '是';
									  }else{
										  return '否';
									  }
								  }}     
							]],
				columns : [ [ 
								
								{field:'FEERATE',title:'费率',sortable:true,width : parseInt($(this).width() * 0.5)},
								{field:'INSERT_DATE',title:'创建时间',sortable:true,width : parseInt($(this).width() * 0.1)},
								{field:'OPER',title:'创建柜员',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'BEGINDATE',title:'生效日期',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'FEE_STATE',title:'费率状态',sortable:true,width : parseInt($(this).width() * 0.08),formatter:function(value,row){
					            	  if(row.FEE_STATE == '0'){
					            		  return '在用';
					            	  }else{
					            		  return '停用';
					            	  }
					              }},
								{field:'CHK_STATE',title:'审核状态',sortable:true,width : parseInt($(this).width() * 0.05),formatter:function(value,row){
					            	  if(row.CHK_STATE == '9'){
					            		  return '待审核';
					            	  }else if(row.CHK_STATE == '0'){
					            		  return '已审核';
					            	  }else{
					            		  return '注销';
					            	  }
					              }},
								{field:'SH_OPER',title:'审核柜员',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'CHK_DATE',title:'审核时间',sortable:true,width : parseInt($(this).width() * 0.1)}
				              ]],toolbar:'#tb',
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
				merchantId:$("#merchantId1").val(),
				trCode:$("#trCode").combobox('getValue'),
				chkState:$("#chkState").combobox('getValue')
			});
		}
		
		//预览merchantRateViewInfo.jsp
		function viewRowsOpenDlg(){
			var rows = $dg.datagrid('getChecked');
			if(rows.length==1){
				$.modalDialog({
					title : "预览费率信息",
					fit:true,
					maximized:true,
					shadow:false,
					//inline:true,
					closable:false,
					resizable:true,
					href : "/merchantRate/merchantRateAction!viewMerchantRate.action?selectRateid="+rows[0].RATEID,
					buttons : [ {
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
		
		
		//弹窗修改
		function updRowsOpenDlg() {
			var rows = $dg.datagrid('getChecked');
			if (rows.length==1) {
				$.modalDialog({
					title : "编辑费率信息",
					iconCls:"icon-edit",
					fit:true,
					maximized:true,
					shadow:false,
					//inline:true,
					closable:false,
					maximizable:false,
					href : "/merchantRate/merchantRateAction!toEidtMerchantRate.action?selectRateid="+rows[0].RATEID,
					buttons : [ {
						text : '编辑',
						iconCls : 'icon-ok',
						handler : function() {
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
			}else{
				$.messager.show({
					title :"提示",
					msg :"请选择一行记录!",
					timeout : 1000 * 2
				});
			}
		}
		//弹窗增加
		function addRowsOpenDlg() {
			$.modalDialog({
				title : "新增费率信息",
				iconCls:"icon-adds",
				fit:true,
				maximized:true,
				shadow:false,
				//inline:true,
				closable:false,
				maximizable:false,
				href : "merchantRate/merchantRateAction!toAddMerchantRate.action",
				buttons : [ {
					text : '保存',
					iconCls : 'icon-ok',
					handler : function() {
						saveAddMerchantRate();
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
		
		function checkRowsOpenDlg(){
			var rows = $dg.datagrid('getChecked');
			if (rows.length==1) {
				$.ajax({
					url:"/merchantRate/merchantRateAction!chkMerRate.action?selectRateid="+rows[0].RATEID,
					success: function(rsp){
						rsp = eval('('+rsp+')');
						parent.$.messager.show({
							title : rsp.title,
							msg : rsp.message,
							timeout : 1000 * 2
						});
						query();
					}
				});
			}else{
				parent.$.messager.show({
					title :"提示",
					msg :"请选择一行记录!",
					timeout : 1000 * 2
				});
			}
		}
		
		function delRowsOpenDlg(){
			var rows = $dg.datagrid('getChecked');
			if (rows.length==1) {
				$.ajax({
					url:"/merchantRate/merchantRateAction!delRate.action?selectRateid="+rows[0].RATEID,
					success: function(rsp){
						rsp = eval('('+rsp+')');
						parent.$.messager.show({
							title : rsp.title,
							msg : rsp.message,
							timeout : 1000 * 2
						});
						query();
					}
				});
			}else{
				parent.$.messager.show({
					title :"提示",
					msg :"请选择一行记录!",
					timeout : 1000 * 2
				});
			}
		}
		
		function autoCom(){
            if($("#merchantId1").val() == ""){
                $("#merchantName1").val("");
            }
            $("#merchantId1").autocomplete({
                position: {my:"left top",at:"left bottom",of:"#merchantId"},
                source: function(request,response){
                    $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantId":$("#merchantId1").val(),"queryType":"1"},function(data){
                        response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
                    },'json');
                },
                select: function(event,ui){
                      $('#merchantId1').val(ui.item.label);
                    $('#merchantName1').val(ui.item.value);
                    return false;
                },
                  focus:function(event,ui){
                    return false;
                  }
            }); 
        }
        function autoComByName(){
            if($("#merchantName1").val() == ""){
                $("#merchantId1").val("");
            }
            $("#merchantName1").autocomplete({
                source:function(request,response){
                    $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantName":$("#merchantName1").val(),"queryType":"0"},function(data){
                        response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
                    },'json');
                },
                select: function(event,ui){
                    $('#merchantId1').val(ui.item.value);
                    $('#merchantName1').val(ui.item.label);
                    return false;
                },
                focus: function(event,ui){
                    return false;
                }
            }); 
        }
	</script>
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>商户费率</strong></span>进行相应操作!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="border-left:none;border-bottom:none;height:auto;overflow:hidden;">
			<div id="tb" >
				<table class="tablegrid" cellpadding="0" cellspacing="0" style="width: 100%">
					<tr>
						<td class="tableleft">商户编号：</td>
						<td class="tableright"><input type="text" name="merchantId" id="merchantId1" class="textinput" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
						<td class="tableleft">商户名称：</td>
						<td class="tableright"><input type="text" name="merchantName" id="merchantName1" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
						<td class="tableleft">交易代码：</td>
						<td class="tableright">
							<select id="trCode" class="easyui-combobox easyui-validatebox" name="trCode" style="width:174px;" >
					    		<option value="">请选择</option>
								<option value="810001">终端_联机消费</option>
								<option value="810101">终端_脱机消费</option>
								<option value="811001">终端_联机消费退货</option>
							</select>
						</td>
						<td class="tableleft">审核状态</td >
						<td class="tableright">
							<select id="chkState" class="easyui-combobox easyui-validatebox" name="chkState" style="width:174px;" >
					    		<option value="">请选择</option>
								<option value="9">待审核</option>
								<option value="0">已审核</option>
								<option value="1">注销</option>
							</select>
						</td>
					</tr>
					<tr>
						<td class="tableright" colspan="8">
							<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="merConsRateView">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-viewInfo"  plain="false" onclick="viewRowsOpenDlg();">预览</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="merConsRateAdd">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"  plain="false" onclick="addRowsOpenDlg();">添加</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="merConsRateEidt">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">编辑</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="merConsRateChcek">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-checkInfo" plain="false" onclick="checkRowsOpenDlg();">审核</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="merConsRateDel">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" plain="false" onclick="delRowsOpenDlg();">删除</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="费率信息"></table>
	  </div>
	  
  </body>
</html>
