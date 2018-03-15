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
    <title>账户激活</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript"> 
		var $dg;
		var oldCardNo = "";
		var cardinfo
		$(function(){
			createSysCode({
				id:"agtCertType",
				codeType:"CERT_TYPE",
				value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
			});
			createSysCode({
				id:"certType",
				codeType:"CERT_TYPE"
			});
			createSysCode({
				id:"cardType",
				codeType:"CARD_TYPE"
			});
			$dg = $("#dg");
			$grid = $dg.datagrid({
				url : "accountManager/accountManagerAction!accEnableQuery.action",
				fit:true,pagination:false,rownumbers:true,border:false,striped:true,fitColumns:true,autoRowHeight:true,scrollbarSize:0,singleSelect:true,
				columns :[[
				       	{field:'V_V',title:'',sortable:true,checkbox:true},
				    	{field:'CUSTOMER_ID',title:'客户编号',sortable:true,width:parseInt($(this).width()*0.05)},
				    	{field:'NAME',title:'姓名',sortable:true,width:parseInt($(this).width()*0.05)},
				    	{field:'GENDER',title:'性别',sortable:true,width:parseInt($(this).width()*0.05)},
				    	{field:'CERT_TYPE',title:'证件类型',sortable:true,width:parseInt($(this).width()*0.05)},
				    	{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width()*0.1)},
				    	{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width()*0.1)},
				    	{field:'CARD_TYPE',title:'卡类型',sortable:true,width:parseInt($(this).width()*0.05)},
				    	{field:'CARD_STATE',title:'卡状态',sortable:true,width:parseInt($(this).width()*0.05)},
				    	{field:'BUS_TYPE',title:'公交类型',sortable:true,width:parseInt($(this).width()*0.05)},
				    	{field:'START_DATE',title:'启用日期',sortable:true,width:parseInt($(this).width()*0.05)}
				]],toolbar:'#tb',
                onLoadSuccess:function(data){
            	   if(data.status != 0){
            		  $.messager.alert('系统消息',data.errMsg,'error');
            	   }else if(data.rows.length > 0){
            		   $(this).datagrid('selectRow',0);
            	   }
                },
                onSelect:function(index,data){
                	if(data == null)return;
     	            $("#accinfo").get(0).src = "jsp/cardService/inneraccinfo.jsp?isChecked=true&cardNo=" + data.CARD_NO;
     	            if($("#accinfodiv").css("display") != "block"){
     		            $("#accinfodiv").show();
     	            }
               }
			});
		});
		//读卡,对卡号进行复制，并设置读卡标志，并设置是好卡
		function readCard(){
			$.messager.progress({text : '正在验证卡信息,请稍后...'});
			cardinfo = getcardinfo();
			if(dealNull(cardinfo['card_No']).length == 0){
				$.messager.progress('close');
				$.messager.alert('系统消息','读卡出现错误，请重新放置好卡片，再次进行读取！','error');
				return;
			}
			$('#cardNo').val(cardinfo['card_No']);
			validCard();
		}
		//验证卡信息
		function validCard(){
			$.post('cardService/cardServiceAction!getCardAndPersonInfo.action',"cardNo=" + $('#cardNo').val(),function(data,status){
				$.messager.progress('close');
				if(status == 'success'){
					$('#certType').combobox('setValue',data.person.certType);
					$('#cardType').combobox('setValue',data.card.cardType);
					if(dealNull(data.card.cardNo).length == 0){
						$.messager.alert('系统消息','验证卡片错误，卡片信息不存在，该卡不能进行账户激活操作！。','error',function(){
							window.history.go(0);
						});
					}else{
						oldCardNo = data.card.cardNo;
						query();
					}
				}else{
					$.messager.alert('系统消息','验证卡信息时出现错误，请重试...','error',function(){
						window.history.go(0);//如果验证通过就进行查询
					});
				}
			},'json');
		}
		function query(){
			deteteGridAllRows('dg');
			if($("#accinfodiv").css("display") == "block"){
				accinfo.window.deleteAllData();
			}
			if($("#certNo").val().replace(/\s/g,'') == '' && $("#cardNo").val().replace(/\s/g,'') == ''){
				$.messager.alert('系统消息','请输入查询证件号码或是卡号！','error');
				return;
			}
			$dg.datagrid('reload',{
				queryType:'0',//查询类型
				"bp.certType":$("#certType").combobox('getValue'), 
				"bp.certNo":$('#certNo').val(), 
				"card.cardType":$("#cardType").combobox('getValue'),
				"card.cardNo":$('#cardNo').val(),
			});
		}
		/**新密码输入*/
		function getNewPwd(){
			if(oldCardNo != $('#cardNo').val()){
				$.messager.alert('系统消息','卡号已发生变化，请重新进行读卡，再进行密码重置！','error',function(){
					window.history.go(0);
				});
			}
			//现在测试阶段读取是的是明文密码，待密码键盘灌密钥后再读取密文密码
			$('#pwd').val(getPlaintextPwd());
			$('#confirmPwd').val(getPlaintextEnsurePwd());
		}
		//提交表单
		function submitForm(){
			var curRow = $dg.datagrid("getSelected");
			if(!curRow){
				$.messager.alert('系统消息','请至少选择一条记录进行卡账户信息激活！','error');
				return;
			}
			var curallacc = accinfo.window.getAllData();
			var curacc = accinfo.window.getSelectedData();
			if(!curallacc || curallacc.length <= 0){
				$.messager.alert('系统消息','该卡不存在未激活的账户信息，无法进行账户激活！','error');
				return;
			}
			if(!curacc){
				$.messager.alert('系统消息','请勾选需要进行激活的账户记录信息！','error');
				return;
			}
			if(curacc.ACC_STATE != 0){
				$.messager.alert('系统消息','勾选的账户记录信息不是【未激活】状态，无法进行激活！','error');
				return;
			}
			//已选择记录
			if($('#pwd').val().replace(/\s/g,'') == ''){
				$.messager.alert('系统消息','请输入新密码！','error');
				return;
			}
			if($('#confirmPwd').val().replace(/\s/g,'') == ''){
				$.messager.alert('系统消息','请输入确认密码！','error');
				return;
			}
			if($('#pwd').val().replace(/\s/g,'') != $('#confirmPwd').val().replace(/\s/g,'')){
				$.messager.alert('系统消息','新密码和确认密码不相同！请重新输入！','error');
				$('#confirmPwd').val('');
				$('#confirmPwd').focus();
				return;
			}
			$.messager.confirm('系统消息','您确定要激活卡号为【' + curRow.CARD_NO + '】的【' + curacc.ACCKIND + '】吗？',function(is){
				if(is){
					$.messager.progress({text : '数据处理中，请稍后....'});
					var reqpara = "cardNo=" + curRow.CARD_NO + "&pwd=" + $("#pwd").val() + "&rec.agtCertType=" + $("#agtCertType").combobox('getValue');
					reqpara += "&rec.agtCertNo=" + $("#agtCertNo").val() + "&rec.agtName=" + $("#agtName").val() + "&rec.agtTelNo=" + $("#agtTelNo").val();
					reqpara += "&accKind=" + curacc.ACC_KIND;
					$.post('/accountManager/accountManagerAction!saveAccEnable.action',reqpara,function(data,status){
						$.messager.progress('close');
						if(status == 'success'){
								$.messager.alert("系统消息",data.msg,(data.status == 0 ? "info" : "error"));
						}else{
							$.messager.progress('close');
							$.messager.alert('系统消息','账户激活发生错误！','error');
						}
					},'json');
				}
			});
		}
		function readIdCard2(){
			var o = getcertinfo();
			if(dealNull(o["name"]).length == 0){
				return;
			}
			$("#certNo").val(o["cert_No"]);
			query();
		}
	</script>
  </head>
  <body class="easyui-layout">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>未激活账户进行激活管理！</strong><span style="color:red;font-weight:700">注意：</span>如果账户不是处于未激活状态则不能进行激活操作！</span></span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
			<div id="tb">
				<table class="tablegrid" cellpadding="0" cellspacing="0">
					<tr>
						<td class="tableleft">证件类型：</td>
						<td class="tableright"><input id="certType" type="text" class="easyui-combobox  easyui-validatebox" name="certType"  style="width:174px;"/></td>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input name="certNo"  class="textinput" id="certNo" type="text"/></td>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" type="text" class="easyui-combobox  easyui-validatebox" name="cardType" style="width:174px;"/></td>
						<td class="tableleft">卡号：</td>
						<td class="tableright"><input name="cardNo"  class="textinput" id="cardNo" type="text"/></td>
					</tr>
					<tr>
						<td class="tableright" colspan="8">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="readCard()">读卡</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-readIdcard" plain="false"   onclick="readIdCard2()">读身份证</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="query()">查询</a>
							<a  href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-signin'" id="subbutton" name="subbutton" onclick="submitForm()">激活</a>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="卡信息"></table>
	  </div>
	  <div data-options="region:'south',split:false,border:true" style="height:300px; width:auto;border-left:none;border-bottom:none;overflow:hidden;">
	  		<div style="width:100%;display:none;" id="accinfodiv">
	  			<h3 class="subtitle">账户信息</h3>
	  			<iframe name="accinfo" id="accinfo"  width="100%" frameborder="0" style="border:none;height:52px;padding:0px;margin:0px;"></iframe>
			</div>
		  	<div style="width:100%;overflow:hidden;height:100%;border:none;" class="datagrid-toolbar">
		  		<h3 class="subtitle">代理人信息</h3>
				<table style="width:100%;" class="tablegrid">
					<tr>
					 	<th class="tableleft">新密码：</th>
						<td class="tableright"><input id="pwd" type="password" class="textinput" name="pwd" maxlength="6"/></td>
						<th class="tableleft">确认密码：</th>
						<td class="tableright" colspan="1">
							<input name="confirmPwd" class="textinput" id="confirmPwd" type="password" maxlength="6"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="getNewPwd()">密码输入</a>
						</td>
						<th class="tableleft">代理人证件类型：</th>
						<td class="tableright"><input id="agtCertType" type="text" class="easyui-combobox" name="rec.agtCertType" value="1" style="width:174px;"/></td>
					</tr>
					<tr>
						<th class="tableleft">代理人证件号码：</th>
						<td class="tableright"><input name="rec.agtCertNo"  class="textinput easyui-validatebox" id="agtCertNo" type="text"  maxlength="18" validtype="idcard" /></td>
						<th class="tableleft">代理人姓名：</th>
						<td class="tableright"><input name="rec.agtName" id="agtName" type="text" class="textinput"  maxlength="30"  /></td>
					 	<th class="tableleft">代理人联系电话：</th>
						<td class="tableright"><input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox"  maxlength="11"  validtype="mobile"/></td>
					</tr>
				</table>
			</div>
	  </div>
  </body>
</html>