<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix ="s" uri="/struts-tags"%>
<script type="text/javascript">
	$(function() {
		
		$("#form").form({
			url :"merchantRegister/merchantRegisterAction!saveMerLmt.action",
			data: $('#form').serialize(),
			onSubmit : function() {
				if($("#merchantId").val()==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '商户名称不能空！',
						timeout : 1000 * 3
	    			});
					return false;
				}
				parent.$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				
				var isValid = $(this).form('validate');
				if (!isValid) {
					parent.$.messager.progress('close');
				}
				return isValid;
				//验证输入框的值
				
			},
			success:function(result) {
				parent.$.messager.progress('close');
				result = $.parseJSON(result);
				if (result.status) {
					parent.reload;
					parent.$.modalDialog.openner.datagrid('reload',{
						queryType:'0'});
					parent.$.modalDialog.handler.dialog('close');
					parent.$.messager.show({
						title :  result.title,
						msg : result.message,
						timeout : 1000 * 2
					});
				}else{
					parent.$.messager.show({
						title :  result.title,
						msg : result.message,
						timeout : 1000 * 2
					});
				}
			}
		});
		
	});
	
	function autoCom(){
        if($("#merchantId").val() == ""){
            $("#merchantName").val("");
        }
        $("#merchantId").autocomplete({
            position: {my:"left top",at:"left bottom",of:"#merchantId"},
            source: function(request,response){
                $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantId":$("#merchantId").val(),"queryType":"1"},function(data){
                    response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
                },'json');
            },
            select: function(event,ui){
                  $('#merchantId').val(ui.item.label);
                $('#merchantName').val(ui.item.value);
                return false;
            },
              focus:function(event,ui){
                return false;
              }
        }); 
    }
    function autoComByName(){
        if($("#merchantName").val() == ""){
            $("#merchantId").val("");
        }
        $("#merchantName").autocomplete({
            source:function(request,response){
                $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantName":$("#merchantName").val(),"queryType":"0"},function(data){
                    response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
                },'json');
            },
            select: function(event,ui){
                $('#merchantId').val(ui.item.value);
                $('#merchantName').val(ui.item.label);
                return false;
            },
            focus: function(event,ui){
                return false;
            }
        }); 
    }
	
    addNumberValidById("lim01");
    addNumberValidById("lim02");
    addNumberValidById("lim03");
    addNumberValidById("lim04");
    addNumberValidById("lim05");
</script>
<div class="easyui-layout" data-options="fit:true,border:false" >
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;padding: 10px;" class="datagrid-toolbar">
		<form id="form" method="post">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>商户限制信息</legend>
				<input name="typeDeal" id="typeDeal" value="${typeDeal}" type="hidden"/>
				 <table class="tablegrid" >
				 	  <tr>
						<th class="tableleft">参数单位说明:</th>
						<td class="tableright" colspan ="3">
						<span style="color:red">涉及到金额的参数一律以分为单位，设置的时候请特别留意！</span>
						</td>
					</tr>
					<s:if test='%{typeDeal=="1"}'>
						<tr>
					 		<td class="tableleft">商户名称：</td>
							<td class="tableright"><input id="merchantId" type="text" class="textinput  easyui-validatebox" name="merLmt.merchantId" value="${merLmt.merchantId}"  onkeydown="autoCom()" onkeyup="autoCom()" readonly="readonly" style="width:174px;cursor:pointer;"  /></td>
							<td class="tableleft">商户名称：</td>
							<td class="tableright"><input type="text" name="merLmt.merchantName" id="merchantName" class="textinput" value="${merLmt.merchantName}" onkeydown="autoComByName()" onkeyup="autoComByName()" readonly="readonly"/></td>
					 	</tr>
					</s:if>
					<s:else>
						<tr>
					 		<td class="tableleft">商户名称：</td>
							<td class="tableright"><input id="merchantId" type="text" class="textinput  easyui-validatebox" name="merLmt.merchantId" value="${merLmt.merchantId}"  onkeydown="autoCom()" onkeyup="autoCom()"  style="width:174px;cursor:pointer;"  /></td>
							<td class="tableleft">商户名称：</td>
							<td class="tableright"><input type="text" name="merLmt.merchantName" id="merchantName" class="textinput" value="${merLmt.merchantName}" onkeydown="autoComByName()" onkeyup="autoComByName()" /></td>
					 	</tr>
					</s:else>
					 <tr>
					 	<th class="tableleft" >单笔限额</th>
						<td class="tableright">
							<input name="merLmt.lim01" value="${merLmt.lim01}"  class="textinput easyui-validatebox" id="lim01" required="required" style="width:174px;"/>
							<span style="color:red;">分</span>
						</td>
						<th class="tableleft" >日累计笔数限制</th>
						<td class="tableright">
							<input name="merLmt.lim02" value="${merLmt.lim02}"  class="textinput easyui-validatebox" id="lim02" required="required" style="width:174px;"/>
						</td>
					</tr>
					<tr>
						<th class="tableleft" >日累计金额限制</th>
						<td class="tableright">
							<input name="merLmt.lim03" value="${merLmt.lim03}"  class="textinput easyui-validatebox" id="lim03" required="required" style="width:174px;"/>
							<span style="color:red;">分</span>
						</td>
						<th class="tableleft" >大额消费界定</th>
						<td class="tableright">
							<input name="merLmt.lim04" value="${merLmt.lim04}"  class="textinput easyui-validatebox" id="lim04" required="required" style="width:174px;"/>
							<span style="color:red;">分</span>
						</td>
					</tr>
					<tr>
						<th class="tableleft" >超过大额报警笔数</th>
						<td class="tableright" colspan="3">
							<input name="merLmt.lim05" value="${merLmt.lim05}"  class="textinput easyui-validatebox" id="lim05" required="required" style="width:174px;"/>
							<span style="color:red;">分</span>
						</td>
					</tr>
				 </table>
			</fieldset>
			</form>
	</div>
</div>
