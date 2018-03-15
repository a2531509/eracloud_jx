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
    <title>卡片解挂</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var $dg;
	var $temp;
	var $grid;
	$(function() {
		/* $("#certType").combobox({
			width:174,
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=CERT_TYPE",
			valueField:'codeValue',
			editable:false,
		    textField:'codeName',
		    panelHeight: 'auto',
		    onSelect:function(node){
		 		$("#certType").val(node.text);
		 	}
		}); */
		createSysCode({id:"cardType",codeType:"CARD_TYPE"});
		$dg = $("#dg");
		$grid=$dg.datagrid({
			url:"cardService/cardServiceAction!queryPayPwdInfo.action",
			fit:true,
			pagination:false,
			rownumbers:true,
			border:false,
			striped:true,
			singleSelect:true,
			fitColumns:true,
			scrollbarSize:0,
			//0未启用1正常2口头挂失3书面挂失9注销
				columns:[ [   
				              {field:'NAME',title:'姓名',width:parseInt($(this).width()*0.1),sortable:true},
				              {field:'CERT_TYPE',title:'证件类型',width:parseInt($(this).width()*0.1)},
				              {field:'CERT_NO',title:'证件号码',width:parseInt($(this).width()*0.1),sortable:true},
				              {field:'CARD_TYPE',title:'卡类型',width:parseInt($(this).width()*0.1)},
				              {field:'CARD_NO',title:'卡号',width:parseInt($(this).width()*0.1),sortable:true},
				              {field:'ISLOCKPWD',title:'是否锁定密码',width:parseInt($(this).width()*0.1),align:'left',editor:"text",formatter:function(value,row,index){
							    	if(value == "是"){return "<span style=\"color:red\">" + value + "</span>"}else{return value;}
							  }}
			              ]],
			   toolbar:'#tb',
               onLoadSuccess:function(data){
            	  if(data.status != 0){
            		  $.messager.alert('系统消息',data.errMsg,'error');
            	  }
            	  if(data.rows.length > 0){
	          	      $(this).datagrid("selectRow",0);
          	      }
	              $("input[type=checkbox]").each(function(){
	      			  this.checked = false;
	      	      });
               }
		});
	});
	//查询
	function query(){
		if($("#cardType").combobox('getValue').replace(/\s/g,'') == ''){
			$.messager.alert("系统消息","请选择查询的卡类型！","error");
			return;
		}
		if($("#cardNo").val().replace(/\s/g,'') == ''){
			$.messager.alert("系统消息","请输入查询的卡号！","error");
			return;
		}
		$dg.datagrid('load',{
			queryType:'0',//查询类型
			/* certType:$("#certType").combobox('getValue'), 
			certNo:$('#certNo').val()*/
			cardType:$("#cardType").combobox('getValue'),
			cardNo:$('#cardNo').val() 
		});
	}
	
	function saveundopwdcard(){
		var row = $dg.datagrid('getSelected');
		if(row){
			if(row.ISLOCKPWD  ==  '否'){
				$.messager.alert("系统消息","卡密码未被锁定，无需解锁","error");
				return;
			}
			$.messager.confirm('系统消息','您确定要对客户为【' + row.CARD_NO + "】的卡进行密码解锁吗？",function(is){
				if(is){
					$.messager.progress({text:'数据处理中，请稍后....'});
					$.post('cardService/cardServiceAction!toSaveUndoPayPwdInfo.action?cardNo=' + row.CARD_NO,function(data){
						$.messager.progress('close');
						$.messager.alert('系统消息',data.msg,(data.status == '0' ? 'info':'error'),function(){
							if(data.status){
								$dg.datagrid('reload');
							}
						});
					},'json');
				}
			});
		}else{
			$.messager.alert("系统消息","请勾选一条卡信息进行解锁！","error");
		}
	}
	
	function readCard(){
		$.messager.progress({text : '正在验证卡信息,请稍后...'});
		cardinfo = getcardinfo();
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.progress('close');
			$.messager.alert('系统消息','读卡出现错误，请重新放置好卡片，再次进行读取！' + cardinfo["errMsg"],'error',function(){
				window.history.go(0);
			});
			return false;
		}
		$("#cardType").combobox("setValue",'100');
		$("#cardNo").val(cardinfo["card_No"]);
		validCard();
	} 
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="overflow: hidden; padding: 0px;">
		<div class="well well-small datagrid-toolbar">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>卡片的交易密码</strong></span>进行解锁操作!</span>
		</div>
	</div>
	<div id="p_layouts" data-options="region:'center',split:false,border:true" style="padding:0px;width:auto;border-bottom:none;border-left:none;">
			<div id="tb" style="padding:2px 0">
				<form id="searchFrom">
					<table class="tablegrid">
						<tr>
							<!-- <td style="padding-left:3px">证件类型：</td>
							<td style="padding-left:3px"><input id="certType" type="text" class="easyui-combobox  easyui-validatebox" name="certType" value="1" style="width:174px;cursor:pointer;"/></td>
							<td style="padding-left:3px">证件号码：</td>
							<td style="padding-left:3px"><input name="certNo"  class="textinput" id="certNo" type="text" maxlength="18"/></td> -->
							<td style="padding-left:3px">卡类型：</td>
							<td style="padding-left:3px"><input id="cardType" type="text" class="easyui-combobox  easyui-validatebox" name="cardType" style="width:174px;"/></td>
							<td style="padding-left:3px">卡号：</td>
							<td style="padding-left:3px"><input name="cardNo"  class="textinput" id="cardNo" type="text" maxlength="20"/></td>
							<td style="padding-left:3px">
								<shiro:hasPermission name="cardLostSave">
									<!--<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>-->
 									<a  data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0)" class="easyui-linkbutton"  id="readcard" name="readcard"  onclick="readCard()">读卡</a>
 									<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
									<a href="javascript:void(0);"  class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-save'" plain="false" onclick="saveundopwdcard();">解锁</a>
								</shiro:hasPermission>
							</td>
						</tr>
					</table>
				</form>
			</div>
	  		<table id="dg" title="密码锁定信息"></table>
	  </div>
</body>
</html>